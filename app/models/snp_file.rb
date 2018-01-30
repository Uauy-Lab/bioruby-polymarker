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
  field :polymarker_path, type: String

  #Outputs
  field :polymarker_output, type: String
  field :mask_fasta, type: String
  field :polymarker_log, type: String

  index({email_hash: 1})

  def status_file
    "#{polymarker_path}_out/status.txt"
  end

  def run_status
    IO.readlines(status_file).last(1)
  end
end
