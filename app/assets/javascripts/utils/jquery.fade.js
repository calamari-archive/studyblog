/**
 * jQuery method that fades away elements after they got read
 * TODO: version with in viewport check
 */
(function($) {
	$.fn.extend({
		fadeAfterReading: function(options) {
		  options = $.extend({
		    // seconds per word
		    perWord: 1,
		    // more time to add on
		    moreTime: 2
		  }, options || {});
		  
		  return this.each(function() {
		    var obj = $(this);
		    setTimeout(function() {
		      obj.fadeOut(options);
		    }, ((options.perWord * obj.text().split(' ').length) + options.moreTime) * 1000);
		  });
		}
	});
})(jQuery);
