class Reference
	include Mongoid::Document
	include Mongoid::Timestamps::Created
	include Mongoid::Timestamps::Updated
	field :name, type: String
	field :path, type: String
	field :genome_count, type: String
	field :arm_selection, type: String
	field :description, type: String
	field :chromosomes, type: Array
	field :example, type: String

	def set_from_hash(h)
		h.each {|k,v| public_send("#{k}=",v)}
	end

	def valid_chromosome?(chr)
		return chromosomes.include? chr if chromosomes
		fasta_file = ReferenceHelper.index_reference(self) unless @local_chromosomes
		@local_chromosomes =  ReferenceHelper.get_chromosomes(self, fasta_file) unless @local_chromosomes
		@local_chromosomes.include? chr
	end

end
