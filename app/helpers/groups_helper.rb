module GroupsHelper

  def populate_startpage_text(text, user)
    data = {
      :studyname => @study.title,
      :date      => I18n.l(Date.current),
      :time      => I18n.l(Time.now),
      :name      => @user.name
    }
    data.each {|key, value| text = text.gsub(Regexp.new('\{' + I18n.t('groups.startpage.replacements.keys.' + key.to_s) + '\}', Regexp::IGNORECASE), value.to_s) }
    text
  end

end
