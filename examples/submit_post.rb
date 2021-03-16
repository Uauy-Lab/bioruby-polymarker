require 'faraday'
require 'pp'
require 'json'

url = 'http://localhost:3000/snp_files.json'

conn = Faraday.new(
  url: 'http://localhost:3000/',
  headers: {'Content-Type' => 'application/json'}
) do |f|
	f.request :multipart
end

payload = {}

payload["snp_file"] = {}
payload["polymarker_manual_input"] ={}
payload["polymarker_manual_input"]["post"] = "1DS_1905169_Cadenza0423_2404_C2404T,1D,ccgccgtcgtatggagcaggccggccaattccttcaaggagtcaaccacctggcgcaaggaccatgaggtccatgctcacgaggtctctttcgttgacgg[C/T]aaaaacaagacggcgccaggctttgagttgctcccggctgtggtggatcaccaaggcaacccgcagccgaccttggtggggatccacgttggccatcccaa\n1DS_40060_Cadenza0423_2998_G2998A,1D,ccagcagcgcccgtcccccttctcccccgaatccgccggagcccagcggacgccggccatgagcacctccgagtagtaagtccccggcgccgccgccgcc[G/A]ccgatctttctttctttctcgcttgatttgtctgcgtttcttttgttccgggtgattgattgatgtgcgtgggctgctgcagcgactacctcttcaagctg\n1DS_1847781_Cadenza0423_2703_G2703A,1D,tttcctctcaaatgtagcttctgcagattcggtggaagggcattcaaccggagaacctcattctcatcacttgcggtcacctctaggtaggacaaaaact[G/A]catctgaataagagactcacagaggcgttcacagtagattctcttcacattcaataacctcaggcttctcatttgcctcagctctcccagttgtctaacag"
payload["snp_file"]["reference"] = "RefSeq v1.0"
payload["snp_file"]["email"]     = ""



js_payload = payload.to_json




resp = conn.post("snp_files.json", js_payload) do |re|
	puts re.path
	puts re.body

end

#puts payload

puts resp.headers

puts resp.body


