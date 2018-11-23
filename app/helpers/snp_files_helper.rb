require 'bio'
require 'bioruby-polyploid-tools'
require 'csv'
require 'net/smtp'
module SnpFilesHelper
	def parse_file(snp_file, polymarker_input, reference)
		#puts snp_file.inspect		
		snp_file.snps = Hash.new
		snp_file.not_parsed = Array.new
		snp_file.output_saved = false
		polymarker_input.tempfile.each_line do |line|
			snp = Bio::PolyploidTools::SNPSequence.parse line
			if  snp.nil? or not reference.valid_chromosome? snp.chromosome
				snp_file.not_parsed << line
			else
				snp.gene.gsub!(".","_")
				snp_file.snps[snp.gene] = [snp.gene, snp.chromosome, snp.sequence_original]
			end
		end
	end

	def parse_manual_input(snp_file, polymarker_input, reference)
		# puts "\n\n\n\nManual parse\n\n\n\n"
		snp_file.snps = Hash.new
		snp_file.not_parsed = Array.new
		snp_file.output_saved = false
		polymarker_input.each_line do |line|
			snp = Bio::PolyploidTools::SNPSequence.parse line
			if  snp.nil? or not reference.valid_chromosome? snp.chromosome
				snp_file.not_parsed << line
			else
				snp.gene.gsub!(".","_")
				snp_file.snps[snp.gene] = [snp.gene, snp.chromosome, snp.sequence_original]
			end
		end
		
	end

	def load_primers_output(snp_file)
		output = Hash.new
		CSV.foreach(snp_file.primers_file, headers:true) do |row|
			tmp_hash = row.to_hash
			output[row["Marker"]] = tmp_hash
		end
		snp_file.polymarker_output = output
	end

	def load_masks(snp_file)
		masks = Hash.new
		current_marker = ""
		print_next = true
		current_id = ""
		Bio::FlatFile.open(Bio::FastaFormat, snp_file.mask_file) do |fasta_file|
		    fasta_file.each do |entry|
					print_this = print_next
					current_marker += entry.to_s if print_this
					if entry.definition.start_with? "MASK"
						print_next = false
						#puts "Saving: #{current_id}"
						masks[current_id] = current_marker
						current_marker=""
					else
						print_next = true
						current_id = entry.definition.split(":")[0]
						current_id.chomp!
					end
				end
		end
		#puts "Now the keys are: #{masks.keys}"
		snp_file.mask_fasta = masks
	end

	def update_status(snp_file)
		return snp_file if snp_file.output_saved == true
		# Send an email if the status is done or has encountered an error
		send_email(snp_file.email,snp_file.id, snp_file.status) if snp_file.email.nil? == false and snp_file.email != "" and (snp_file.status.include? "DONE" or snp_file.status.include? "ERROR")
		snp_file.status = snp_file.run_status[0] if snp_file.run_status.size > 0
		if snp_file.status.include? "DONE"
			snp_file.polymarker_log = snp_file.run_lines.join("")
			load_primers_output(snp_file)
			load_masks(snp_file)
			snp_file.output_saved = true
		end
		snp_file.save!
		snp_file
	end

	def get_mail_opt
		return @mail_opt if @mail_opt
		client_path  = Rails.root.join('config', 'mail_properties.yml')
        config_mail = YAML.load_file(client_path)
        @mail_opt = config_mail["mail_opt"]
        @mail_opt
	end

	def send_email(to,id, status)

		options = get_mail_opt

msg = <<END_OF_MESSAGE
From: #{options['email_from_alias']} <#{options['email_from']}>
To: <#{to}>
Subject: Polymarker #{id} #{status}

The current status of your request (#{id}) is #{status}
The latest status and results (when done) are available in: #{request.original_url}
END_OF_MESSAGE
	    smtp = Net::SMTP.new options["email_server"], 587
	    smtp.enable_starttls
	    smtp.start( options["email_domain"], options["email_user"], options["email_pwd"], :login) do
		smtp.send_message(msg, options["email_from"], to)
    end
  end

end
