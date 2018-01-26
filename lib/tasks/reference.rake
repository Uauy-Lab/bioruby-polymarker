require 'bio-samtools'
require 'bioruby-polyploid-tools'

namespace :reference do
	desc "Add a fasta file"
	task :add, [:file] => :environment do |t, args|
		fasta_file = args[:file]
		fasta_samtools = Bio::DB::Fasta::FastaFile.new(
			fasta: fasta_file,
			samtools: true)
		if File.exists?  "#{args[:file]}.fai"
			$stdout.puts "#{args[:file]} already indexed"
		else
			$stdout.puts "Indexing #{args[:file]}"
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

		

	end

	desc "TODO"
	task select_order: :environment do
	end

end
