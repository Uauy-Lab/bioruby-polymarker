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
  field :output_saved, type: Boolean

  #Outputs
  field :polymarker_output, type: Hash
  field :mask_fasta, type: Hash
  field :polymarker_log, type: String

  index({email_hash: 1})

  def status_file
    "#{polymarker_path}_out/status.txt"
  end

  def primers_file
    "#{polymarker_path}_out/primers.csv"
  end

  def mask_file
    "#{polymarker_path}_out/exons_genes_and_contigs.fa"
  end


  def run_status
    run_lines.last(1)
  end

  def run_lines
    IO.readlines(status_file)
  end
end
