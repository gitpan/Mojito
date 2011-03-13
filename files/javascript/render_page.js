// A central place to store application variables
var mojito = {};
var got_content, oneshot, resizeEditArea, fetchPreview;
/* global prettyPrint: false */

var oneshot_preview = oneshot();
var oneshot_pause = 1000; // Time in milliseconds.
var on_change_refresh_rate = 10000;
var resizeTimer;
	
$(document).ready(function() {

	$('#content').each(function() {
		this.focus();
	});

	resizeEditArea();
	$(window).resize(function() {
		clearTimeout(resizeTimer);
		resizeTimer = setTimeout(resizeEditArea, 100);
	});
	$('textarea#content').autoResize({ 
	    extraSpace : 60
    }).trigger('change');
	
	prettyPrint();
	$('#content').keyup(function() {
		fetchPreview.only_every(on_change_refresh_rate);
		oneshot_preview(fetchPreview, oneshot_pause);
	});
	
	$('#submit_create').click(function() {
		// if no content : no submit
		return got_content();
	});
	$('#submit_save').click(function() {
		fetchPreview('save');
		return false;
	});
	$('#page_delete').click(function() {
		alert("Are you sure?");
		return false;
	});
	$('#recent_articles_label').click(function() {
		  $('#recent_area').toggle('slow', function() {
		    // Animation complete.
		  });
		  $('.view_area_view_mode').width('90%');
	});
});

function got_content() {
	var content = $('textarea#content').val();
	if (!content || content.match(/^\s+$/)) {
		return false;
	}
	else {
		return true;
	}
}

fetchPreview = function(extra_action) {
	var content = $('textarea#content').val();
	var mongo_id = $('#mongo_id').val();
	var data = { 
			 content: content,
			 mongo_id: mongo_id,
			 extra_action: extra_action
		   };
	// Don't submit ajax request if we have trivial content
	if (!content || content.match(/^\s+$/)) {
		return false;
	}

	var ajaxOptions = {
		type : 'POST',
		url  : mojito.preview_url,
		data : data,
		success : function(response, status) {
			$('#view_area').html(response.rendered_content);
			prettyPrint();
	    },
		error : function(XMLHttpRequest, textStatus, errorThrown) {
			alert("Error: " + textStatus + " thrown: " + errorThrown); 
		},
		dataType : 'json'
	};

	$.ajax(ajaxOptions);

	return true;
};

function resizeEditArea() {
	// Check that we have an edit_area first.
	if ( $('#edit_area').length ) {
		mojito.edit_area_fraction = 0.46;
		mojito.edit_width = Math.floor( $(window).width() * mojito.edit_area_fraction);
		//console.log('resizing edit area to: ' + mojito.edit_width);
		$('textarea#content').css('width', mojito.edit_width + 'px');
	}
}

function oneshot() {
	var timer;
	return function(fun, time) {
		clearTimeout(timer);
		timer = setTimeout(fun, time);
	};
}

// Based on
// http://www.germanforblack.com/javascript-sleeping-keypress-delays-and-bashing-bad-articles
Function.prototype.only_every = function(millisecond_delay) {
	if (!window.only_every_func) {
		var function_object = this;
		window.only_every_func = setTimeout(function() {
			function_object();
			window.only_every_func = null;
		}, millisecond_delay);
	}
};
