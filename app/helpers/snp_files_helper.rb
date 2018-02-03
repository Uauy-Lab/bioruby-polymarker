require 'bioruby-polyploid-tools'
require 'csv'
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

	def update_status(snp_file)
		snp_file.status = snp_file.run_status[0] if snp_file.run_status.size > 0
		snp_file.polymarker_log = snp_file.run_lines.join("")

		load_primers_output(snp_file)
		snp_file.save!
	end
end
