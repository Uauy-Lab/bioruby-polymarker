load_primers_table = function (snp_file_id, div, done) {

	var grid_div = $("#" + div);
	var primers_url =  snp_file_id  +'/input.json';
	
	var general = [
		{name: 'ID', caption:'ID', width: '100px'},
		{name: 'Chr', caption:'Chr', width: '40px'}
	]

	var polymarker_output = [
	{name: 'total_contigs', caption:'Matches', width: '20px'},
	{name: 'SNP_type', caption:'Type', width: '65px'},
	{name: 'A', caption:'A', width: '150px'},
	{name: 'B', caption:'B', width: '150px'},
	{name: 'common', caption:'Common', width: '150px'},
	{name: 'primer_type', caption:'Primer type', width: '80px'},
	{name: 'errors', caption:'Errors', width: '205px'},
	]

	var sequence = [
		{name: 'Sequence', caption:'Sequence', width: '820px'}
	]

	if(done){
		general = general.concat(polymarker_output);
	}else{
		general = general.concat(sequence);
	}
	
	columns_array = general
	grid_div.jsGrid({
		filtering: true,
        editing: false,
        sorting: true,
        paging: true,
        autoload: true,
		
		//url: primers_url,
		fields: columns_array,
		controller: {
            loadData: function() {
                var d = $.Deferred();
 				console.log("Loading?");
                $.ajax({
                    url: primers_url,
                    dataType: "json"
                }).done(function(response) {
                	console.log("Respones");
                	console.log(response.records);
                	console.log(d.resolve);
                    d.resolve(response.records);
                });
 
                return d.promise();
            }
        },
		rowClick: function(event) {
			console.log(event);
		}
	});

	
	
};


load_mask = function(snp_file_id, marker, local_msa ){
	var fasta_url = snp_file_id + "/" + marker + ".fasta" ;
	var seqs = fasta.read(fasta_url);
	seqs.then(function(result) {
		console.log(result);
		local_msa.seqs.add(result);
		local_msa.render();
	});
}

setup_msa_div = function (div) {
	
	var div_obj = document.getElementById(div);
	var local_msa = new msa.msa({
		el: div_obj,
		//seqs: seqs,
		zoomer: {
			labelWidth: 100,

			alignmentWidth: 1000 ,
			labelFontsize: "13px",
			labelIdLength: 50
		},
		g:{
			conserv: false,
			registerMouseClicks: false,
			scheme: "nucleotide",
			allowRectSelect : false,
			width: "960px"
		}

	}) ;
	local_msa.g.vis.set("conserv",  false);
	local_msa.g.vis.set("registerMouseClicks", false);
	local_msa.g.colorscheme.set("scheme", "nucleotide");
	local_msa.g.config.set("registerMouseClicks", false);
	return local_msa;
};

function httpGet(theUrl)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false ); // false for synchronous request
    xmlHttp.send( null );
    return xmlHttp.responseText;
}
