var controls = controls || {};

/**
 * Fileuploader
 * @param {jQuery} uploadElement jQuery representation of the fileupload element
 * @param {Object} options Some options
 * @param {Function} [options.done=null] Callback to call when image was uploaded
 * @param {String}   [options.url=null] url to post, defaults to parent form action
 */
controls.Fileuploader = function(uploadElement, options) {
  var container      = uploadElement.parents('div.uploader'),
      button         = container.find('button'),
      errorMessage   = container.find('.input-error'),
      successMessage = container.find('.input-success');


  function processError(e, data) {
    if (data.result && data.result.error) {
      errorMessage.html(data.result.error).show().fadeAfterReading();
    }
  }

  uploadElement.fileupload({
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
    dataType: 'json',
    url: options.url || uploadElement.parents('form').attr('action'),
    dropZone: null
  })
  .bind('fileuploaddone', function(e, data) {
    if (data.result.success) {
      options.done(data.result);
      successMessage.show().fadeAfterReading();
    } else {
      processError(e, data);
    }
  })
  .bind('fileuploadstart', function(e, data) {
    uploadElement.prop('disabled', true);
    button.addClass('disabled');
    container.find('.spinner').show();
    successMessage.add(errorMessage).hide();
  })
  .bind('fileuploadstop', function(e, data) {
    uploadElement.prop('disabled', false);
    button.removeClass('disabled');
    container.find('.spinner').hide();
  })
  .bind('fileuploadfail', processError);
};
