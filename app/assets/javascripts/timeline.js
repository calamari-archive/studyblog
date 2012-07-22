//= require ./controls/layer.js

/**
 * Shows a timeline of the group
 *
 * @params {Boolean} [options.showEndLine] Should the finishing line be drawn?
 */
var Timeline = function(element, options) {
	element = $(element);
	options = $.extend({
		dayInPixel: 200, // How much space should a day be in pixel width
		offset:     50,  // offset in pixels where to start first day
		actualTime: 0	   // Actual time as floating point (day 3 12th hour = 3.5)
	}, options || {});
	var users    = element.find('.users'),
		entries    = element.find('.articles li.entry'),
		comments   = element.find('.comments li.entry'),
		topics     = element.find('.topics li.entry'),
		topicMarkers = [],
		numberDays = options.days || 0, // show only this number of days if set
		actualTime = new Date().getTime(),
		actualPos  = calculatePosition(actualTime),
		startTime  = options.startTime,
		endTime    = options.endTime,
		clicked    = false;

	function initialize() {
		positionElements();
		numberDays = Math.ceil(numberDays);
		for (var i=0; i < numberDays; ++i) {
		//TODO: position the text centered above ruler
			createRuler(i, {
				text: 'Tag ' + (i+1)
			});
		}
		/* TODO: MOVEing now ruler */
		if(!numberDays || actualPos <= numberDays) {
			createRuler(options.actualTime, { className: 'actual' });
		} else {
		  // TODO: show study ended message
		}

		createRuler(numberDays, { className: 'end-ruler' });

    // a spacer
		createRuler(numberDays + 1, { className: 'invisible' });

		element.css({
			width: (numberDays * options.dayInPixel + options.offset) + 'px'
		});

		createRuler(calculatePosition(actualTime), { className: 'actual-time' });

		showTopics();

		startObservers();
		initTooltips();
	};

	function showTopics() {
	  var MARKER_OFFSET = -1;
	  topics.each(function(i, topic) {
	    var $topic = $(topic),
  		    ruler = $('<div class="topic-marker" style="left: ' + (Math.max(0, calculatePosition($topic.data('time'))) * options.dayInPixel + options.offset) + 'px"><span>' + ($topic.data('title')) + '<div class="arrow"></div></span></div>'),
  		    span  = ruler.find('span'),
  		    arrow  = ruler.find('div.arrow');
  		// calculate dimensions and size of topic span
  		element.append(ruler);
  		span.css({
  		  position: 'absolute',
  		  left: -(span.width() / 2) + 'px',
  		  top: -(span.height() + MARKER_OFFSET) + 'px',
  		  width: span.width() + 'px'
  		});
  		arrow.css({
  		  position: 'absolute',
  		  left: (span.width() / 2 - 31) + 'px',
  		  top: (span.height() - 15) + 'px',
  		  width: arrow.width() + 'px'
  		});
  		topicMarkers.push(ruler);
	  });
	}

	/**
	 * Creates the line that shows a mark in the timeline
	 * @param {Number} left time in timeline where to show marker
	 * @param {Object} [options] Some further options
	 * @param {Object} [options.text=''] Text to show above the marker
	 * @param {Object} [options.className=''] class name to add to the ruler
	 */
	function createRuler(left, opts) {
		opts = opts || {};
		var ruler = $('<div class="ruler' + (opts.className ? ' ' + opts.className : '') + '" style="left: ' + (left * options.dayInPixel + options.offset) + 'px"><span>' + (opts.text || '') + '</span></div>');
		element.append(ruler);
	};

	/**
	 * Positions all entries according to their time data
	 */
	function positionElements() {
		element.find('.entry').each(function(i, element) {
			element = $(element);
			var pos = calculatePosition(element.data('time'));
			element.css({ left: (pos * options.dayInPixel + options.offset) + 'px' });
			numberDays = Math.max(numberDays, pos);
		});
	}

	function calculatePosition(time) {
	  return (time - startTime) / (3600000 * 24)
	}

	function initTooltips() {
	  $('.timeline .entry').tooltip({
	    extraClass: 'timeline',
	    bodyHandler: function() {
	      return this.innerHTML;
	    }
	  });
	}

	function startObservers() {
		entries.mouseover(function(event) {
			if(!clicked) {
				var target = $(event.currentTarget);
				entries.css({ opacity: 0.5 });
				target.css({ opacity: 1 });
				comments.filter('[data-entryid=' + target.data('id') + ']').show();
				event.stopPropagation();
			}
		});
		entries.click(function(event) {
			clicked = clicked ? false : $(event.currentTarget);
		});
		entries.mouseout(function(event) {
			if(!clicked) {
				var target = $(event.currentTarget);
				entries.css({ opacity: 1 });
				comments.filter('[data-entryid=' + target.data('id') + ']').hide();
			}
		});

		element.mousemove(function(event) {
		  var threshold = 10,
		      mouseX = event.layerX;
		  $.each(topicMarkers, function(i, ruler) {
		    var x = ruler.position().left;
		    if (mouseX < x + threshold && mouseX > x - threshold) {
		      ruler.addClass('hover');
		    } else {
		      ruler.removeClass('hover');
		    }
		  });
		});
	};

	initialize();
};
