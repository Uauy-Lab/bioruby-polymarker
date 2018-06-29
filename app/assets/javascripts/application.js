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



// Hide the messages when it's clicked on
	function hideMessage(){
		$(".alert").on("click", function(event) {
			$(this).hide();
		});
	}

// Caldulate the margin between logos (Needs 300 milisecond delay for images to load first)
	function calculateLogoMargin(){
		setTimeout(function(){			
			var totalWidth = 0;
			$(".footer img").each(function(){
				totalWidth =  totalWidth + $(this).width();    
			});  
			$(".logo").css("margin-left", ((window.innerWidth - totalWidth)/10)-10 );
			$(".logo").css("margin-right", ((window.innerWidth - totalWidth)/10)-10 );
		}, 300);		
	}

// Resizing the logos dynamically when window resized
	function spaceLogosDynamically(){
		var resizeLogoTimer;
		$(window).on('resize', function(e){      
			clearTimeout(resizeLogoTimer);  // Making sure that the reload doesn't happen if the window is resized within 1.5 seconds (1200 = 1500 - 300)
			resizeLogoTimer = setTimeout(function(){
				calculateLogoMargin();
			}, 1200);
		});
	}	

// Execute functions when the content of the window are loaded
var ready;
ready = (function() {
	
	calculateLogoMargin();

	spaceLogosDynamically()

	hideMessage();	

});

$( window ).on( "load", ready);