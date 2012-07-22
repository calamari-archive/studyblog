var controls = controls || {};

/**
 * Shows a modal Background that is dark
 */
controls.ModalBackground = function() {
	var modalLayer = $('#modalbackground'),
		setModalLayerSize = function() {
			modalLayer.css({
				position: 'fixed',
				left: 0,
				top: 0,
				height: $(window).height() + 'px',
				width: $(window).width() + 'px'
			});
		};

	if(!modalLayer.length) {
		modalLayer = $('<div id="modalbackground"></div>');
		$('body').append(modalLayer);
	}
	modalLayer.show();
	setModalLayerSize();
	$(window).resize(setModalLayerSize);
	return {
		remove: function() {
			modalLayer.hide();
			$(window).unbind('resize', setModalLayerSize);
		}
	};
}
