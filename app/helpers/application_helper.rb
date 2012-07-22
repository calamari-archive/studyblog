module ApplicationHelper
  def page_title(name, vars = {})
    name = I18n.t name, vars
    puts name
    content_for(:title) { name + " | " + I18n.t(:browser_title) }
    content_tag "h1", name
  end

  def javascript_time(time)
    time.to_i * 1000
  end

  def studies_options
    if @study
      actual_study = @study
    elsif @group
      actual_study = @group.study
    elsif @blog
      actual_study = @blog.study
    end
    options_for_select([[I18n.t('application.header.no_study'), '']] | Study.all_of_moderator(current_user).map {|study| [study.title, study.id] }, actual_study ? actual_study.id : nil)
  end

  # adds a span.kern around letter paris To and Wa to make that more prettier
  def kern(text)
    text.gsub(/(T)(o)|(W)(a)/, '<span class="kern">\1\3</span>\2\4').html_safe
  end

  def emoticons(text)
    {
      'angel' => /[0O]\:\-?\)/,
      'smile' => /\:\-?\)/,
      'laugh' => /\:\-?D/,
      'xd'    => /[xX]\-?D/,
      'silly' => /\:\-?[pP]/,
      'wink'  => /\;\-?\)/,
      'sad'   => /\:\-?\(/,
      'cry'   => /\;\-?\(/,
      'zipit' => /\:\-?[xX]/,
      'kiss'  => /\:\-?\*/,
      'cool'  => /B\-?\)/,
      'geek'  => /8\-?\)/,
      'shock' => /o\.O/,
      'angry' => /\>\-?\(/,
      'surprised'  => /[^(http)]\:\-?[\/\\]/,
      'speechless' => /\:\-?\|/,
      'love'  => /\<3/
    }.each do |emoticon, pattern|
      #text = text.gsub(/\:\-?\)/, 'DDDDD')
      text = text.gsub(pattern, '<img class="emo emoticons-' + emoticon  + '" src="' + asset_path('transparent.gif') + '" width="19" height="19">')
      #text = text.gsub pattern, img_tag(:src => '/images/emoticons/' + img + '.png')
    end
    text.html_safe
  end
end
