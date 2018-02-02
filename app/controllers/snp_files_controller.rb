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
     @snp_file = SnpFile.new
     form_snp_file = snp_file_params
     @snp_file.email = form_snp_file[:email]
     @snp_file.filename = form_snp_file[:polymarker_input].original_filename
     @snp_file.email_hash = Digest::MD5.hexdigest @snp_file.email
     @snp_file.status = "New"

     reference = Reference.find_by(name: form_snp_file[:reference])

     @snp_file.reference = reference.name
     parsed_file = helpers.parse_file(@snp_file, form_snp_file[:polymarker_input], reference)

     #puts "___Aabout to save____"
    if @snp_file.save!
      #puts @snp_file.inspect
      PolyMarkerWorker.perform_async(@snp_file.id)
      redirect_to snp_file_path(@snp_file), notice: "New snp file" and return
    end
    render 'new'
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

  def show_input
    @snp_file = SnpFile.find params["id"]
     records = array_to_json(@snp_file.snps.values, ["ID", "Chr", "Sequence"] )
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
end
