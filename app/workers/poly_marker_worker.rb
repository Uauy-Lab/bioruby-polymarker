class PolyMarkerWorker
  include Sidekiq::Worker
  require 'sidekiq/api'
  require 'net/smtp'
  require 'fileutils'

  def update_status(snp_file, status)

    send_stat_email snp_file if snp_file.status == "New"

    snp_file.status = status    

    # Remove the temporary folder and file where PolyMarker ran
    if snp_file.status.include? "DONE" or snp_file.status.include? "ERROR"
      path_pref = Preference.find_by( {key:"execution_path"})
      # Email the status and remove it
      send_stat_email snp_file      
      file_path = snp_file.id.to_s
      file_path = "#{path_pref.value}/#{snp_file.id.to_s}" if path_pref
      FileUtils.rm(file_path)
    end

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
    #puts "preparing input file: #{path}"

    f=File.open(path, "w")
    snp_file.snps.each_pair  do |key, row|
      f.puts(row.join(","))
    end
    f.close
    snp_file.polymarker_path = path
    update_status(snp_file, "Input file ready")
  end

  def perform(new_id, base_url)
    $base_url = base_url
    snp_file = SnpFile.find new_id
    write_polymarker_input snp_file
    execute_polymarker(snp_file)
  end

  def get_mail_opt
    return @mail_opt if @mail_opt
    client_path  = Rails.root.join('config', 'mail_properties.yml')
        config_mail = YAML.load_file(client_path)
        @mail_opt = config_mail["mail_opt"]
        @mail_opt
  end

  def send_stat_email(snp_file)

    if snp_file.email.nil? == false and snp_file.email != ""
      send_email(snp_file.email,snp_file.id, snp_file.status, snp_file.id.to_s)
      # Removing email from the database when process is finished or encountered an error
      snp_file.email = "" if snp_file.status != "New"
    end   
    
  end

  def send_email(to,id, status, snp_id)

    options = get_mail_opt

    results_url = "#{$base_url}/snp_files/#{snp_id}"

msg = <<END_OF_MESSAGE
From: #{options['email_from_alias']} <#{options['email_from']}>
To: <#{to}>
Subject: Polymarker #{id} #{status}

The current status of your request (#{id}) is #{status}
The latest status and results (when done) are available in: #{results_url}
END_OF_MESSAGE
      smtp = Net::SMTP.new options["email_server"], 587
      smtp.enable_starttls
      smtp.start( options["email_domain"], options["email_user"], options["email_pwd"], :login) do
    smtp.send_message(msg, options["email_from"], to)
    end
  end  

end
