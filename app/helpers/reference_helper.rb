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
		project = {"$project" => 
			{
				"reference" => "$reference",
				"snps_size" => {"$size" => {  "$objectToArray" => "$snps" }} ,
				"year"    => { "$year"  => "$created_at"}, 
				"month"   => { "$month" => "$created_at"}
			}
		}

		references_agg =  { 
			"$group"=> { 
				"_id"   => { 
					"reference" => "$reference", 
					"year" => "$year", 
					"month" => "$month"
				},
				"total" => { "$sum" => 1 },
				"markers_count" => { "$sum" => "$snps_size" }
				 } 
			}

		tmp = SnpFile.collection.aggregate([project, references_agg])
		summary = []
		tmp.each do |e|
			id = e["_id"]
			extra = ""
			extra = "0" if id["month"] < 10
			arr = []
			arr << id["reference"]
			arr << id["year"].to_s + "-"  + extra +   id["month"].to_s
			arr << e["total"]
			arr << e["markers_count"]
			summary << arr
		end
		
		df = Daru::DataFrame.rows(
			summary, 
			order: [:reference, :month, :count_requests, :count_markers] )
			#order: [:month, :reference, :count_markers, :count_requests, :mean_runtime, :done])
		#$stderr.puts df.inspect
		df
	end

	def self.summary_by_month_outside_mongo
		tmp_rows = []
		SnpFile.each do |e|
			tmp_rows  << [
				e.reference ,
				e.status ,
				e.updated_at ,
			 	e.updated_at - e.created_at ,
			 	"#{e.updated_at.strftime "%Y-%m"}",
			 	e.snps.size,
			 	e.status.include?( "DONE" ) ? 1 : 0
			 	] 
		end

		df = Daru::DataFrame.rows(tmp_rows, 
			order: [:reference, :status, :updated, :runtime, :month, :markers_no, :done])
		

		groups = df.group_by([:month, :reference])

		summary = []
		groups.each_group do |dfg|
			month = dfg[:month].first
			reference = dfg[:reference].first
			summary << [
				month,
				reference,
				dfg[:markers_no].sum,
				dfg[:markers_no].size,
				dfg[:runtime].mean,
				dfg[:done].sum
			]
			#$stderr.puts dfg.inspect
			#$stderr.puts dfg[:markers_no].sum
		end
		 
		df = Daru::DataFrame.rows(summary, 
			order: [:month, :reference, :count_markers, :count_requests, :mean_runtime, :done])
		#$stderr.puts df.inspect
		df
	end
end
