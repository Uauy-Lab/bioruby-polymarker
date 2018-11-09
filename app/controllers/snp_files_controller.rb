require 'digest'

class SnpFilesController < ApplicationController
  def index
  end

  def new
    @snp_file = SnpFile.new
    #puts @snp_file.inspect
    @snp_file
  end

  def create
    
    begin      
      @snp_file = SnpFile.new
      puts "\n\n\n\nYOLO\n\n\n\n"
      form_snp_file = snp_file_params
      @snp_file.email = form_snp_file[:email]
      @snp_file.filename = form_snp_file[:polymarker_input].original_filename if File.file?(form_snp_file[:polymarker_input]) # If input is file
      @snp_file.email_hash = Digest::MD5.hexdigest @snp_file.email
      @snp_file.status = "New"

      reference = Reference.find_by(name: form_snp_file[:reference])

      @snp_file.reference = reference.name      


      if File.file?(form_snp_file[:polymarker_input]) # If input is file
        parsed_file = helpers.parse_file(@snp_file, form_snp_file[:polymarker_input], reference)
      else
        parsed_file = helpers.parse_manual_input(@snp_file, form_snp_file[:polymarker_input], reference)
      end      
      
      #puts "___Aabout to save____"
      puts @snp_file.inspect
      if @snp_file.save!
        #puts @snp_file.inspect
        PolyMarkerWorker.perform_async(@snp_file.id)
        redirect_to snp_file_path(@snp_file), notice: "SNP file uploaded successfully" and return
      end

      render 'new'

    rescue => e    
      flash[:error] = "Please attach a CSV file with the correct data format"
      puts e
      session[:return_to] ||= request.referer
      redirect_to session.delete(:return_to)
      return
    end     

  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show

    @snp_file = SnpFile.find params["id"]
    if @snp_file.status != "New"
      helpers.update_status  @snp_file
    end

    @is_done = ((@snp_file.status.include? "ERROR") || (@snp_file.status.include? "DONE"))

  end

  def array_to_json(records_array, fields)

    records=Array.new
    records_array.each do |record|
      record_h = Hash.new
      record.each_with_index do |e, i|
        record_h[fields[i]] = e == nil ? "": e
      end
      records << record_h
    end
    {"total" => records.size, "records" =>records}
  end

  def get_mask
    @snp_file = SnpFile.find params["id"]    
    @fasta = @snp_file.mask_fasta[params["marker"]]#.gsub ':', '_'   
  end

  def get_snps_and_markers(snp_file)
    markers = array_to_json(snp_file.snps.values, ["ID", "Chr", "Sequence"] )
    return markers if !status.nil? and not snp_file.status.include? "DONE"
    markers_a = markers["records"]
    new_records = Array.new
    markers_a.each do |e|
      id =  e["ID"]
      polymarker_input = snp_file.polymarker_output[id]
      polymarker_input["primer_type"] = polymarker_input["primer_type"].sub("chromosome_","") if polymarker_input["primer_type"]
      polymarker_input["SNP_type"] = polymarker_input["SNP_type"].sub("homoeologous","hom") if polymarker_input["SNP_type"]

      new_records << e.merge(polymarker_input)
    end
    new_records.first.keys.each { |e| puts "{field: '#{e}', caption:'#{e}', size: '50px'}, \n" }
    markers["records"] = new_records
    markers
  end

  def show_input
    @snp_file = SnpFile.find params["id"]    
     records = get_snps_and_markers(@snp_file)
     #records["value"] = records["records"]
     respond_to do |format|
       format.html
 			 format.json {
 				render json: records
 			}
    end
  end

  def snp_file_params
    params.require(:snp_file).permit(:email, :reference, :polymarker_input)
  end

  def get_mask_file

    snp_file = SnpFile.find params["id"]    

    fasta = snp_file.mask_fasta
    fasta_data=''
        

    fasta.each do |key, value|
      fasta_data += value  
    end    

    send_data fasta_data, filename: "exons_genes_and_contigs.fa"
    
  end


  def get_primers

    snp_file = SnpFile.find params["id"]

    primer_data = snp_file.polymarker_output    
    primer_headers = primer_data.values[0].keys.join(",")
    primer_values = ''        

    primer_output = CSV.generate do |csv|
      csv << [primer_headers]
    end

    primer_data.each do |key, value|      
      primer_values = value.values.join(",")      

      primer_output += CSV.generate do |csv|
        csv << [primer_values]
      end

    end    

    send_data primer_output, filename: "Primers.csv"
    
  end


end
