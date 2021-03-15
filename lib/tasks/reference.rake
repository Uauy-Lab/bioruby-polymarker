require 'bio-samtools'
require 'bioruby-polyploid-tools'
require 'yaml'

namespace :reference do
	desc "Add a fasta file from a preferences file (see examples folder)"
	Mongoid.load!("config/mongoid.yml")
	task :add, [:file] => :environment do |t, args|
		refs = YAML.load_file(args[:file])
		puts "-------"
		pp refs
		refs.each do |v|
			puts "*****"
			pp v
			insert = false
			ref = Reference.find_by({:name => v["name"]})
			insert = true if ref.nil?
			ref = Reference.new unless ref
			ref.set_from_hash v
			fasta_file = ReferenceHelper.index_reference(ref)
			chromosomes = ReferenceHelper.get_chromosomes(ref, fasta_file)
			$stdout.puts "Observed chromosomes: #{chromosomes.size}"
			ref.chromosomes = chromosomes  if chromosomes.size < 50000
			if insert
				ref.save!
			else
				ref.update!
			end

		end
	end

	desc "TODO"
	task select_order: :environment do
	end

	desc "Prints a summary of how many requests happened per month"
	task :summary => :environment do |t, args|
		summ = ReferenceHelper.summary_by_month
		$stderr.puts summ.inspect
		#daru_to_console summ , STDERR
	end

end
