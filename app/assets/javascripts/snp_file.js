 function load_primers_table(snp_file_id, div, done, local_msa) {
	var grid_div = $("#" + div);
	var primers_url =  snp_file_id  +'/input.json';
	var general = [
		{name: 'ID', title:'ID', width: '200px'},
		{name: 'Chr', title:'Chr', width: '40px'}
	]
	var polymarker_output = [
	{name: 'total_contigs', title:'Aln', width: '30px'},
	{name: 'SNP_type', title:'Type', width: '65px'},
	{name: 'A', title:'A', width: '150px'},
	{name: 'B', title:'B', width: '150px'},
	{name: 'common', title:'Common', width: '150px'},
	{name: 'primer_type', title:'Primer type', width: '80px'},
	{name: 'errors', title:'Errors', width: '105px'},
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
		pageSize: 15,
		fields: columns_array,
		updateOnResize: true,
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

function find_end_with_gaps(opts){
    var args = {start:0, length:0, seq:null} ;
    if (opts.start) args.start = opts.start;
    if (opts.length)args.length = opts.length;
    if (opts.seq)args.seq = opts.seq;
    // console.log(args);
    var sequence = args.seq.toUpperCase();
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
    var args = {end:50, length:0, seq:null}     ;
    if (opts.end) args.end = opts.end;
    if (opts.length) args.length = opts.length;
    if (opts.seq) args.seq = opts.seq;
    var sequence = args.seq.toUpperCase();
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

function find_target_sequence(item, seqs){
	var target = item["Chr"];
	var chr_index = 0;
	var i = 0;
	current_best = 0;
	seqs.map( function(seq) {
		var split = seq.name.split("-");
		var name_tmp = split[split.length - 1];
		if(split.length > 1) {
			var split_2 = name_tmp.split("_")
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


function get_primer_coordinates(item, chr_index, seqs){
	// console.log(seqs);
	// console.log(item);
	var a=seqs[0].seq;
	var b=seqs[1].seq;
	var c=b;
	var left_most = 0;

	if(seqs[chr_index]){
		c=seqs[chr_index].seq;
	}
	var mask = seqs[seqs.length-1];
	var index_snp = mask.seq.indexOf("&") ;
	if(index_snp < 0){
		index_snp = mask.seq.indexOf(":");
	}

	var a_b_start = index_snp;
	var lengh_a = item["A"].length
	var lengh_c = item["common"].length
	var product_size = item["product_size"]
	var left_most = index_snp - lengh_a;

	var end_obj = find_end_with_gaps({
		start:index_snp,
		length:lengh_a,
	 	seq:c
	});

	//console.log("We passed the first search")
	var a_c_end = end_obj.end - 1;

	var start_obj = find_start_with_gaps({
		end:end_obj.end,
		length:product_size,
		seq:c
	});
	//console.log("We passed the second search")
	var common_index = start_obj.start;

	var end_obj_2 = find_end_with_gaps({
		start:common_index,
		length:lengh_c,
		seq:c,
	});

	var common_start = common_index;
	var common_end = end_obj_2.end - 1;
	return {
		a_start: a_b_start, 
		a_end: a_c_end,
		common_start: common_start,
		common_end: common_end, 
		c:c, 
		b:b
	}

}


function load_mask(snp_file_id, item, local_msa ){
	var marker = item["ID"];
	var fasta_url = snp_file_id + "/" + marker + ".fasta" ;
	var seqs = fasta.read(fasta_url);
	var gffParser = msa.io.gff;

	
	seqs.then(function(result) {
		// console.log(result);
		//local_msa.seqs.add(result);
		local_msa.seqs.reset(result);
		local_msa.render();
		local_msa.g.selcol.reset()
		var chr_index = find_target_sequence(item, result);
		var coordinates = null;
		if(item.primer_type != null){
			coordinates = get_primer_coordinates(item,chr_index, result);
		} else {
			return;
		}
		// console.log(coordinates);
		
		if(chr_index >= 0 && coordinates.c != coordinates.b){
			
			var se = new msa.selection.possel({
		 	xStart: coordinates.a_start,
				xEnd: coordinates.a_end,
				seqId: 0});

			var se2 = new msa.selection.possel({
				xStart: coordinates.a_start,
				xEnd: coordinates.a_end,
				seqId: 1});

			var se3 = new msa.selection.possel({
				xStart: coordinates.common_start,
				xEnd: coordinates.common_end,
				seqId: chr_index});


			var view_start = coordinates.a_start;
			if(view_start > coordinates.common_start){
				view_start = coordinates.common_start
			}
			local_msa.g.zoomer.setLeftOffset(view_start); 
			// console.log(local_msa.g.selcol);
			
			local_msa.g.selcol.add(se);
			local_msa.g.selcol.add(se2);
			local_msa.g.selcol.add(se3);
		}
	});


	setTimeout(function(){
		var nameWidth = $(".biojs_msa_labelblock").width();		
		$(".biojs_msa_rheader").css('margin-left', nameWidth - 150);
		// var windowWidth = $(window).width();
		// zoomerWidth = windowWidth - nameWidth - 100;		
		// local_msa.g.zoomer.attributes.alignmentWidth = zoomerWidth;		
	}, 100);
}

function setup_msa_div (div) {	
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
