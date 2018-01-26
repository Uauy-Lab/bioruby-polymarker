module ReferenceHelper
	def self.index_reference(reference)
		fasta_file = reference.path
		fasta_samtools = Bio::DB::Fasta::FastaFile.new(
			fasta: fasta_file,
			samtools: true)
		if File.exists?  "#{fasta_file}.fai"
			$stdout.puts "#{fasta_file} already indexed"
		else
			$stdout.puts "Indexing #{fasta_file}"
			$stdout.flush
			fasta_samtools.index() 
		end

		if File.exists? "#{fasta_file}.nal" or File.exists? "#{fasta_file}.nhr"
			$stdout.puts "#{fasta_file} seems to be have a blast database already"
		else
			$stdout.puts "Creating blast database for #{fasta_file}"
			$stdout.flush
			cmd = "makeblastdb  -dbtype 'nucl' -in #{fasta_file} -out #{fasta_file}"
			system cmd
		end
		fasta_samtools
	end
end
