/**
 * jQuery method that opens a dialog
 */
(function($) {
  var modalLayer,
    body,
    win,
    element,
    openedDialog,
    closeHandler,
    closer,
    keyHandler,
    lastOptions;

  var scrollHandler = function() {
    updatePosition(20);
  };

  /**
   * Updates the position of the dialog (for example after resizing window)
   * @param {Number} time Time in milliseconds the transistion will take
   * @param {Function} [callback] Callback function to call after transition is done
   */
  var updatePosition = function(time, callback) {
    var scrollTop = win.scrollTop();
    element.clearQueue().animate({
      left: (win.scrollLeft() + (win.width() - element.width())/2) + 'px',
      top: Math.max(scrollTop, (scrollTop + (win.height() - element.height())/2)) + 'px',
      duration: time
    }, callback || function() {});
  };

  /**
   * Opens Dialog
   * @param {jQuery} ele jQuery enhanced element that is used as dialog content
   * @param {Object} options some options:
   * @param {Function} [options.onBeforeOpen] callback that is called before opening dialog
   * @param {Function} [options.onOpen] callback that is called after opening dialog
   */
  var openDialog = function(ele, options) {
    element = ele;
    element.addClass('dialog');
    var dialogCloser = element.find('.dialog-x');
    if (options.closeX && !dialogCloser.length) {
      dialogCloser = $('<span class="dialog-closer dialog-x">×</span>');
      element.append(dialogCloser);
    }
    body.append(element);
    options.onBeforeOpen && options.onBeforeOpen(element);
    element.css({
      position: 'absolute',
      left: (win.scrollLeft() + (win.width() - element.width())/2) + 'px',
      top: (-element.height()) + 'px'
    });
    element.show();
    updatePosition(500, function() {
      options.onOpen && options.onOpen(element);
    });
    openedDialog = element;
    win.bind('scroll.dialog', scrollHandler)
      .bind('resize.dialog', scrollHandler);
  };

  /**
   * Closes the dialog again
   */
  var closeDialog = function() {
    options = lastOptions || {};
    if (openedDialog) {
      var dialog = openedDialog;
      /** fire event before it statrs to close */
      options.onBeforeClose && options.onBeforeClose(openedDialog);
      openedDialog.animate({
        left: ((body.width() - openedDialog.width())/2) + 'px',
        top: (-openedDialog.height() - 100) + 'px'
      }, function() {
        modalLayer && modalLayer.remove();
        dialog.remove();
        /** fire event when it is closed */
        options.onClose && options.onClose(openedDialog);
      });
      openedDialog = null;
      /** unbind closing handler */
      closer && closer.unbind('.dialog', closeHandler);
      win.unbind('.dialog');
    }
  };

  $.fn.extend({
    dialog: function(options) {
      options = $.extend({
        modal: false,
        closer: '.dialog-closer',
        closeX: true
      }, options || {});

      body = $('body');
      win = $(window);

      if (options.modal) {
        modalLayer = options.modal = new controls.ModalBackground();
      }
      openDialog(this, options);
      lastOptions = options;
      closeHandler = function(event) {
        closeDialog();
        event.preventDefault();
      };
      closer = this.find(options.closer).on('click.dialog', closeHandler);
      if (!keyHandler) {
        keyHandler = function(event) {
          if (event.which == 27) {
            closeDialog();
          }
        };
        $(window).keydown(keyHandler);
      }
      return this;
    }
  });

  $.closeDialog = closeDialog;
  $.updateDialogPosition = updatePosition;

})(jQuery);
