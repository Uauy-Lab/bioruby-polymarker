require 'bioruby-polyploid-tools'
module SnpFilesHelper
	def parse_file(snp_file, polymarker_input, reference)
		puts snp_file.inspect
		snp_file.snps = Hash.new
		snp_file.not_parsed = Array.new
		polymarker_input.tempfile.each_line do |line|
			snp = Bio::PolyploidTools::SNPSequence.parse line
			if  snp.nil? or not reference.valid_chromosome? snp.chromosome
				snp_file.not_parsed << line
			else
				snp_file.snps[snp.gene] = [snp.gene, snp.chromosome, snp.sequence_original]
			end	
		end
	end
end
