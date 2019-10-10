require 'bio'
require 'bioruby-polyploid-tools'
require 'csv'
require 'fileutils'
module SnpFilesHelper
	def parse_file(snp_file, polymarker_input, reference)
		#puts snp_file.inspect		
		snp_file.snps = Hash.new
		snp_file.not_parsed = Array.new
		snp_file.output_saved = false
		polymarker_input.tempfile.each_line do |line|
			polyploid_parse_input(snp_file, line, reference)
		end
	end

	def parse_manual_input(snp_file, polymarker_input, reference)
		# puts "\n\n\n\nManual parse\n\n\n\n"
		snp_file.snps = Hash.new
		snp_file.not_parsed = Array.new
		snp_file.output_saved = false
		polymarker_input.each_line do |line|
			polyploid_parse_input(snp_file, line, reference)
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
		snp_file.status = snp_file.run_status[0] if snp_file.run_status.size > 0		

		if snp_file.status.include? "DONE"
			snp_file.polymarker_log = snp_file.run_lines.join("")
			load_primers_output(snp_file)
			load_masks(snp_file)
			snp_file.output_saved = true			
			remove_directory_and_remove_job(snp_file)
		end		

		#remove_directory_and_remove_job(snp_file) if snp_file.status.include? "ERROR"

		snp_file.save!
		snp_file
	end

	def store_job_in_local_queue snp_id

		$job_queue.push(snp_id) unless $job_queue.include?(snp_id)

	end


	def get_job_queue_index snp_id
		if $job_queue.size > 0 and $job_queue.include?(snp_id)
			hash = Hash[$job_queue.map.with_index.to_a]
			return hash[snp_id] + 1
		else
			return 0
		end	

	end

	def polyploid_parse_input(snp_file, line_input, reference)
		line_input.gsub!("\t",",")
		arr = line_input.split(",")
		arr[2] = arr[2].upcase
		line_input = arr.join(",")

		snp = Bio::PolyploidTools::SNPSequence.parse line_input
		if  snp.nil? or not reference.valid_chromosome? snp.chromosome
			snp_file.not_parsed << line_input
		else
			snp.gene.gsub!(".","_")
			snp_file.snps[snp.gene] = [snp.gene, snp.chromosome, snp.sequence_original]
		end
	end

	def remove_directory_and_remove_job(snp_file)
		path_pref = Preference.find_by( {key:"execution_path"})
		prefix = "."
		prefix = path_pref.value if path_pref
		dir_name = "#{prefix}/#{snp_file.id.to_s}_out"
		FileUtils.remove_dir(dir_name)
		$job_queue.delete(snp_file.id)
	end

	private

	$job_queue = []

end
