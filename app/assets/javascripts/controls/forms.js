var controls = controls || {};
controls.forms = {};

/**
 * Form Textinput for the Startpage
 */
controls.forms.SimpleForm = function(elementId, doneCallback) {
  var wysihtml = new wysihtml5.Editor(elementId, {
    style:       false,
    toolbar:     "toolbar",
    stylesheets: [
      globals.assetBaseDir + "elements/wysihtml5.css",
      globals.assetBaseDir + "application.css"
    ],
    parserRules: wysihtml5.parserRules
  });
};

/**
 * Form Textinput for the Startpage
 */
controls.forms.FormWithImages = function(elementId, config) {
  controls.forms.SimpleForm(elementId);

  var uploadElement  = $('#image-upload'),
      container      = uploadElement.parents('.uploader'),
      button         = container.find('button'),
      editorField    = container.find('[data-wysihtml5-dialog-field=src]')
      editorSendBtn  = container.find('[data-wysihtml5-dialog-action=save]');
  new controls.Fileuploader(uploadElement, {
    url: config.url,
    done: function(result) {
      editorField.val(result.image);
      uploadElement.val('');
    }
  });
};
