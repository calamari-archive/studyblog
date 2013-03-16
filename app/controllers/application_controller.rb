class ApplicationController < ActionController::Base
  protect_from_forgery
  # check if every sub controller has authorization defined
  check_authorization

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404 unless Rails.env.development?

#  before_filter { |c| Authorization.current_user = c.current_user }

  before_filter :check_if_participant_and_study_has_ended

#  before_filter { |c| redirect_to deactivated_path if c.current_user && c.current_user.deactivated }

  # Only germany for now
  before_filter { Time.zone = 'Berlin' }

  helper_method :current_user

  def render_404
    render 'errors/404'
  end

  protected
    def test
      Authorization.current_user = current_user unless current_user.nil?
    end

    def check_if_participant_and_study_has_ended
      if current_user && (current_user.is_participant? || current_user.is_spectator?)
        redirect_to study_ended_url if current_user.study.has_ended?
      end
    end

    def permission_denied
      flash[:alert] = t('application.messages.permission_denied')
      redirect_to root_url
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
#      @current_user_session = UserSession.new if defined?(@current_user_session)
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
#      puts "Auth?" + @current_user.name if !@current_user.nil?
#      puts "--Authorization.current_user is set" if defined?(Authorization.current_user) && !Authorization.current_user.nil?
#      puts "--current_user is set" if defined?(current_user) && !current_user.nil?
#      puts "user:" + @current_user.name
#       @current_user
    end
end
