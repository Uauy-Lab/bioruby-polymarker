load_primers_table = function (snp_file_id, div, done, local_msa) {
	var grid_div = $("#" + div);
	var primers_url =  snp_file_id  +'/input.json';
	var general = [
		{name: 'ID', title:'ID', width: '100px'},
		{name: 'Chr', title:'Chr', width: '40px'}
	]
	var polymarker_output = [
	{name: 'total_contigs', title:'Aln', width: '30px'},
	{name: 'SNP_type', title:'Type', width: '65px'},
	{name: 'A', title:'A', width: '150px'},
	{name: 'B', title:'B', width: '150px'},
	{name: 'common', title:'Common', width: '150px'},
	{name: 'primer_type', title:'Primer type', width: '80px'},
	{name: 'errors', title:'Errors', width: '205px'},
	]
	var sequence = [
		{name: 'Sequence', title:'Sequence', width: '810px'}
	]
	if(done){
		general = general.concat(polymarker_output);
	}else{
		general = general.concat(sequence);
	}
	
	columns_array = general
	grid_div.jsGrid({
		filtering: false,
        editing: false,
        sorting: true,
        paging: true,
        autoload: true,
		pageSize: 5,
		fields: columns_array,
		controller: {
            loadData: function() {
                var d = $.Deferred();
                $.ajax({
                    url: primers_url,
                    dataType: "json"
                }).done(function(response) {
                    d.resolve(response.records);
                });
 
                return d.promise();
            }
        },
		rowClick: function(event) {
			load_mask(snp_file_id, event.item, local_msa);
		}
	});
};

unction find_end_with_gaps(opts){
    var args = {start:0, length:0, seq:null, validate:null, skip:false} ;
    if (opts.start) args.start = opts.start;
    if (opts.length)args.length = opts.length;
    if (opts.seq)args.seq = opts.seq;
    if (opts.validate)args.validate = opts.validate;
    if (opts.skip)args.skip = opts.skip;
    var sequence = args.seq.seq.toUpperCase();
    var to_count = args.length;
    var i;

    for(i = args.start; i < sequence.length && to_count > 0; i++){
        if(sequence[i] != '-'){
           to_count--;
       }
    }

    var ret ={};
    ret.sequence = sequence.substring(args.start, i)  ;
    ret.end = i;
    return ret;

}

function find_start_with_gaps(opts){
    var args = {end:50, length:0, seq:null, validate:null, skip:false}     ;
    if (opts.end) args.end = opts.end;
    if (opts.length) args.length = opts.length;
    if (opts.seq) args.seq = opts.seq;
    if (opts.validate)args.validate = opts.validate;
    if (opts.skip) args.skip = opts.skip;
    var sequence = args.seq.seq.toUpperCase();
    var to_count = args.length;
    var i;
    for(i = args.end; i > 0 && to_count > 0; i--){
       if(sequence[i] != '-'  ){
           to_count--;
       }
    }

    var ret ={};
    ret.sequence = sequence.substring(i, args.end)  ;
    ret.start = i;
    return ret;

}

find_target_sequence = function(item, seqs){
	var target = item["Chr"];
	var chr_index = 0;
	var i = 0;
	current_best = 0;
	seqs.map( function(seq) {
		var split = seq.name.split("-");
		var name_tmp = split[split.length - 1];
		if(split.length > 1) {
			var split_2 = name_tmp.split("_")
			console.log(split_2);
			var name = split_2[0];
			var score = parseFloat(split_2[2])
			if(name== target && score > current_best){
				chr_index = i;
				current_best = score;
			}
		}
		i++;
	});
	return chr_index;
}



load_mask = function(snp_file_id, item, local_msa ){
	var marker = item["ID"];
	var fasta_url = snp_file_id + "/" + marker + ".fasta" ;
	var seqs = fasta.read(fasta_url);
	console.log(local_msa.seqs)
	
	local_msa.seqs.reset();
	seqs.then(function(result) {
		console.log(result);
		var chr_index = find_target_sequence(item, result);
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
