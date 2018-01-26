require 'bio-samtools'
require 'bioruby-polyploid-tools'
require 'yaml'

namespace :reference do
	desc "Add a fasta file"
	task :add, [:file] => :environment do |t, args|
		refs = YAML.load_file(args[:file])
		refs.each_pair do | k, v|
			insert = false
			ref = Reference.find_by({:name => v["name"]})
			insert = true if ref.nil?
			ref = Reference.new unless ref
			ref.set_from_hash v
			ReferenceHelper.index_reference(ref)

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

end
