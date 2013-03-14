var controls = controls || {};

(function($win) {
  'use strict';
  /**
   * Shows a modal Background that is dark
   */
  controls.ModalBackground = function() {
    var modalLayer        = $('#modalbackground'),
        setModalLayerSize = function() {
          modalLayer.css({
            position: 'fixed',
            left: 0,
            top: 0,
            height: $win.height() + 'px',
            width: $win.width() + 'px'
          });
        };

    if(!modalLayer.length) {
      modalLayer = $('<div id="modalbackground"></div>');
      $('body').append(modalLayer);
    }
    modalLayer.show();
    setModalLayerSize();
    $win.resize(setModalLayerSize);
    return {
      remove: function() {
        modalLayer.hide();
        $win.unbind('resize', setModalLayerSize);
      }
    };
  };
})($(window));
