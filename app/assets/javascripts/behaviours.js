
$(document).ready(function() {
  $('[data-confirm]').live('click', function(event) {
		var target = $(event.currentTarget),
			text   = target.data('confirm'),
			method = target.data('method') || 'get',
			dialog = $('<form method="' + (method === 'get' ? 'get' : 'post') + '" action="' + target.attr('href') + '"><h4>' + text + '</h4><button type="submit" class="submit-button">Ok</button><button type="button" class="dialog-closer cancel-button">Abbrechen</button></form>');
		dialog.select('form').append('<input type="hidden" name="_method" value="' + method + '">');
		dialog.dialog({
			modal: true,
			closeX: false
		});
		event.preventDefault();
		event.stopPropagation();
  });

  $('a[data-method=post]').live('click', function(event) {
    if ($(event.currentTarget).attr('data-confirm')) { return; }
    $('<form method="post"></form>').attr('action', event.currentTarget.href).submit();
    event.preventDefault();
  });

  $('a[data-method=delete]').live('click', function(event) {
    if ($(event.currentTarget).attr('data-confirm')) { return; }
    var form = $('<form method="post" style="display:none"></form>').attr('action', event.currentTarget.href);
    $(document.body).append(form.append('<input type="text" name="_method" value="delete">'));
    form.submit();
    event.preventDefault();
  });

  $('[data-toggle]').live('click', function(event) {
    var clickTarget = $(event.target),
        target      = $('#' + clickTarget.data('toggle')),
        hideTarget  = clickTarget.data('toggle-hide');
    hideTarget  = hideTarget ? $('#' + hideTarget) : clickTarget;
    hideTarget.hide();
    target.show();
    target.find('textarea,input:visible:first').focus();
    target.find('.cancel').one('click', function(event) {
      hideTarget.show();
      target.hide();
      event.preventDefault();
    });
    event.preventDefault();
    // TODO: enhance with cancel logic...
  });
  // preopen toggles
  $('.toggleopen').each(function(i, target) {
    $("[data-toggle='" + target.id + "']").click();
  });

  $('.fileupload input.file').live('change', function(event) {
    $(this).parents('form').submit();
  });

  $('.datepicker').datepicker({
    firstDay: 1,
    dateFormat: globals.dateFormat,
    dayNamesMin: globals.dayNamesMin,
    monthNames: globals.monthNames
  });

  $('select.dropdown').dropkick({
    theme: 'study',
    change: function(id) {
      console.log(this, arguments, $(this).find("[value='" + id + "']"), id);
      $(this).find("[value='" + id + "']").attr("checked", "checked");
    }
  });

  /**
   * clickable area that opens an url
   */
  $('body').on('click', '[data-clickarea]', function(event) {
    var target = $(event.target),
        div;
        console.log(target.closest('a'));
    if (!target.closest('a').length) {
      div = target.closest('[data-clickarea]');
      location.href = div.attr('data-clickarea');
    }
    else {
      console.log("OK");
    }
  });


  /**
   * Tooltips
   */
  $('[data-tooltip]').filter(function(i, element) {
    return $(element).attr('data-tooltip') !== '';
  }).tooltip({
    bodyHandler: function() {
      return $(this).attr('data-tooltip');
    }
  });

  // For autofocus
  $('[autofocus]').focus();
});
