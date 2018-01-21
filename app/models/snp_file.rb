class SnpFile
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  field :filename, type:String
  field :email, type: String
  field :status, type:String
  field :snps,  type: Hash
  field :polymarker_output, type: String
  field :mask_fasta, type: String
  field :polymarker_log, type: String

end
