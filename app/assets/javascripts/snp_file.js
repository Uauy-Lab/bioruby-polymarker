load_primers_table = function (snp_file_id, div) {

	var grid_div = $("#" + div);
	console.log(grid_div);
	var fasta_url =  snp_file_id  +'/input.json';
	console.log(fasta_url);
	grid_div.w2grid({
		name: div,
		method: 'GET',
		show: {
			toolbar: true,
			footer: true,
			toolbarReload: false
		},
		fixedBody : true,
		url: fasta_url,
		columns: [
		{field: 'ID', caption:'ID', size: '240px'},
		{field: 'Chr', caption:'Chr', size: '50px'},
		{field: 'Sequence', caption:'Sequence', size: '600px'}
		]
	});
};


setup_msa_div = function (snp_file_id, marker , div) {
	
	var div_obj = document.getElementById(div);
	
	var fasta_url = snp_file_id + "/" + marker + ".fasta" ;
	seqs = fasta.read(fasta_url);

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
			allowRectSelect : false
		}

	}) ;
	local_msa.g.vis.set("conserv",  false);
	local_msa.g.vis.set("registerMouseClicks", false);
	local_msa.g.colorscheme.set("scheme", "nucleotide");
	local_msa.g.config.set("registerMouseClicks", false);


	console.log("setting up msa");
	console.log(seqs);
	console.log(seqs.value);

	seqs.then(function(result) {
		console.log(result);
		local_msa.seqs.add(result);
	local_msa.render();
	console.log(local_msa);
});
	
	
	return local_msa;
};

function httpGet(theUrl)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", theUrl, false ); // false for synchronous request
    xmlHttp.send( null );
    return xmlHttp.responseText;
}
