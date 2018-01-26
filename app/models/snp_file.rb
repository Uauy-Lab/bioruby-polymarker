class SnpFile
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  #Inputs
  field :filename, type: String
  field :email, type: String
  field :email_hash, type: String
  field :snps,  type: Hash
  field :reference, type: String
  
  #Control
  field :status, type: String
  field :not_parsed, type: Array

  #Outputs
  field :polymarker_output, type: String
  field :mask_fasta, type: String
  field :polymarker_log, type: String
  
end
