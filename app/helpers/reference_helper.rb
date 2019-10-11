require "daru"

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

	def self.get_chromosomes(reference, fasta_file)
		fasta_file.load_fai_entries
		arm_selection = reference.arm_selection
		#valid_functions   = Bio::PolyploidTools::ChromosomeArm.getValidFunctions
		
		selction_function = Bio::PolyploidTools::ChromosomeArm.getArmSelection(arm_selection)
		raise "Invalid reference parser (#{arm_selection}, valid: #{valid_functions}" unless selction_function
		fasta_file.index.entries.map do |e| 
			s = selction_function.call e.id 
			raise Exception.new "Invalid chromosome name '#{e.id}' for parser #{arm_selection}" if s.nil? or s.length == 0
			s 
		end.uniq
	end

	def self.summary_by_month

		reference   = []
		status      = []
		updated     = []
		runtime     = []
		month       = []

		SnpFile.each do |e|
			reference << e.reference
			status    << e.status
			updated   << e.updated_at
			runtime   << e.created_at - e.updated_at
			month     << "#{e.updated_at.strftime "%Y-%m"}" 

			tmp = {
				reference: e.reference,
				status: e.status,
				updated: e.updated_at,
				runtime: e.created_at - e.updated_at
			}	
		end
		df = Daru::DataFrame.new(
			month: month,
			reference: reference,
			status: status,
			updated: updated,
			runtime: runtime,
			)
		df
	end
end
