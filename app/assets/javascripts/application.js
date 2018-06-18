// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require snp_file.js

$(document).ready(function($) {

	// Spacing between logos when page initially loaded
		var totalWidth = 0;
		$(".footer img").each(function(){
			totalWidth =  totalWidth + $(this).width();    
		});  
		$(".logo").css("margin-left", ((window.innerWidth - totalWidth)/10)-10 );
		$(".logo").css("margin-right", ((window.innerWidth - totalWidth)/10)-10 );

	// Resizing the logos dynamically 
		var resizeLogoTimer;
		$(window).on('resize', function(e){      
			clearTimeout(resizeLogoTimer);  // Making sure that the reload doesn't happen if the window is resized within 1.5 seconds
			resizeLogoTimer = setTimeout(function(){      
				$(".logo").css("margin-left", ((window.innerWidth - totalWidth)/10)-10 );
				$(".logo").css("margin-right", ((window.innerWidth - totalWidth)/10)-10 );
			}, 1500);
		});
	
});