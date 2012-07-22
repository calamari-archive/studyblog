var controls = controls || {};

/**
 * Opens a layer
 * @param {String|Element} content The content of the layer, that will be appended/moved to body
 * @param {Object} options Some options
 * @param {String} [options.position=false] 'top', 'bottom', 'left', 'right' of some element, if false then you can position it yourself
 * @param {Selector|Element} options.positionTarget where to position it
 */
controls.Layer = function(content, options) {
	var element = $('<div class="layer"></layer>').append(content),
		positionDir = options.position || 'below',
		target = $(options.positionTarget),
		body = $('body');

	element.appendTo(body);
	show();

	function show() {
		if (positionDir === 'above' || positionDir === 'below') {
			element.css({
				position: 'absolute',
				left: target.offset().left + 'px',
				top: (target.offset().top + target.height()) + 'px'
			});
		} else {
		}
		element.show();
	};

	function hide() {
		element.hide();
		console.log("hide", element);
	};
	
	function remove() {
		element.remove();
	};
	
	return {
		hide: hide,
		show: show,
		remove: remove
	};
};
