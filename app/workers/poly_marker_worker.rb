class PolyMarkerWorker
  include Sidekiq::Worker

  def update_status(snp_file, status)
    snp_file.status = status
    snp_file.save!
  end

  def execute_command(command, type=:text, skip_comments=true, comment_char="#", &block)
    puts "Executing #{command}"
    stdin, pipe, stderr, wait_thr = Open3.popen3(command)
    pid = wait_thr[:pid]  # pid of the started process.
    if type == :text
      while (line = pipe.gets)
        next if skip_comments and line[0] == comment_char
        yield line.chomp if block_given?
      end
    elsif type == :binary
      while (c = pipe.gets(nil))
        yield c if block_given?
      end
    end
    exit_status = wait_thr.value  # Process::Status object returned.
    puts stderr.read
    stdin.close
    pipe.close
    stderr.close
    return exit_status
  end

  def execute_polymarker(snp_file)

    update_status(snp_file, "Running")
    ref = Reference.find_by({name: snp_file.reference})

    #cmd=@properties['wrapper_prefix']
    cmd = "polymarker.rb -m #{snp_file.polymarker_path} -o #{snp_file.polymarker_path}_out "
    cmd << "-c #{ref.path} "
    cmd << "-g #{ref.genome_count} "
    cmd << "-a #{ref.arm_selection} "
    cmd << "-A blast"
    #cmd << @properties['wrapper_suffix']
    #polymarker.rb -m 1_GWAS_SNPs.csv -o 1_test -c /Users/ramirezr/Documents/TGAC/references/Triticum_aestivum.IWGSP1.21.dna_rm.genome.fa
    execute_command(cmd)

    update_status(snp_file, snp_file.run_status)
  end

  def write_polymarker_input(snp_file)
    path_pref = Preference.find_by( {key:"execution_path"})
    path = "."
    update_status(snp_file, "Preparing input file")
    if path_pref
      path = path_pref.value
    else
      path = Dir.pwd
      $stderr.puts "WARN: 'execute_path' is empty. Using current path (#{path})."
    end

    path = "#{path}/#{snp_file.id}"
    puts "preparing input file: #{path}"

    f=File.open(path, "w")
    snp_file.snps.each_pair  do |key, row|
      f.puts(row.join(","))
    end
    f.close
    snp_file.polymarker_path = path
    update_status(snp_file, "Input file ready")
  end

  def perform(new_id)
    snp_file = SnpFile.find new_id
    write_polymarker_input snp_file
    execute_polymarker(snp_file)
  end
end
