class UserMailer < ActionMailer::Base
  default :from => StudyBlog::Application.config.app_config['mails']['from']['no_reply']

  #test this (like in: http://edgeguides.rubyonrails.org/action_mailer_basics.html)
  def new_participant(user, testmail=nil)
    @user = user
    @study = user.study
    email_with_name = testmail || "#{@user.name} <#{user.email}>"
    mail(:to => email_with_name, :subject => I18n.t('users.participant.new.mail.subject', :study => @study.title))
  end

  def new_participant_from_mailing(user, mailing, testmail=nil)
    @user = user
    @study = user.study
    email_with_name = testmail || "#{@user.name} <#{user.email}>"
    #todo parse in the right infos into mailing.text
    @text = populate_mailing_with_data(mailing.text)
    mail(:to => email_with_name, :subject => I18n.t('users.participant.new.mail.subject', :study => @study.title))
  end

  #test this (like in: http://edgeguides.rubyonrails.org/action_mailer_basics.html)
  def new_spectator(user)
    @user = user
    @study = user.study
    email_with_name = "#{@user.name} <#{user.email}>"
    mail(:to => email_with_name, :subject => I18n.t('users.new_spectator.mail.subject'))
  end

  #test this (like in: http://edgeguides.rubyonrails.org/action_mailer_basics.html)
  def delete_spectator(user)
    @user = user
    @study = user.study
    email_with_name = "#{@user.name} <#{user.email}>"
    mail(:to => email_with_name, :subject => I18n.t('users.delete_spectator.mail.subject'))
  end

  def self.mailing_keys
    ['studyname', 'startdate', 'enddate', 'url', 'duration', 'name', 'mail', 'password' ]
  end

  def self.mailing_descriptions
    self.mailing_keys.map {|key| { :key => I18n.t('user_mailer.replacements.keys.' + key), :desc => I18n.t('user_mailer.replacements.descriptions.' + key) } }
  end

  protected

  def populate_mailing_with_data(text)
    data = {
      :studyname =>  @study.title,
      :startdate =>  I18n.l(@study.start_date),
      :enddate =>    I18n.l(@study.end_date),
      :url =>        root_path,
      :duration =>   @study.duration,
      :name =>       @user.name,
      :mail =>       @user.email,
      :password =>   @user.password
    }
    data.each {|key, value| text = text.gsub(Regexp.new('\{' + I18n.t('user_mailer.replacements.keys.' + key.to_s) + '\}', Regexp::IGNORECASE), value.to_s) }
    text
  end
end
