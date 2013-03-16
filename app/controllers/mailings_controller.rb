class MailingsController < ApplicationController
  before_filter :load_study, :except => :save
  before_filter :check_study_status, :except => :save
  before_filter :load_mailing_for_new, :only => :new
  before_filter :create_study, :only => :create

  filter_access_to :all, :attribute_check => true

  def show
    @mailing = Mailing.find(params[:id])
    p @mailing
    render :action => :edit
  end

  def new
    @available_mailings = [[t('mailings.load_form.no_mailing_selected'), '']] |
      Mailing.all_of_owner(current_user).map {|mailing| [mailing.name, mailing.id] }

    if (@study.mailing_defined?)
      render :action => :edit
    end
  end

  def edit
    @mailing = Mailing.find(params[:id])

    @available_mailings = [[t('mailings.load_form.no_mailing_selected'), '']] |
      Mailing.all_of_owner(current_user).map {|mailing| [mailing.name, mailing.id] }
  end

  def create
    @mailing.study = @study

    params[:mailing].each {|key, value| @mailing[key] = value }
    if send_testmail(params)
      flash[:notice] = t('mailings.messages.testmail_send')
      render :action => :new
    elsif @mailing.save
      redirect_to study_url(@study), :notice => t('mailings.messages.saved')
    else
      render :action => :new
    end
  end

  # TODO: Why was here GET allowed?
  def save
    @mailing = Mailing.find(params[:id])

    if @mailing.is_saved?
      redirect_to edit_mailing_url(@mailing), :notice => t('mailings.messages.already_saved')
    end

    if request.method == "POST"
      @mailing.name = params[:mailing][:name]
      @mailing.owner = current_user
      if @mailing.save
        redirect_to study_url(@mailing.study), :notice => I18n.t('mailings.messages.mailing_saved', :name => @mailing.name)
      else
        flash[:alert] = I18n.t('mailings.messages.mailing_not_saved')
      end
    end
  end

  def load
    @study.mailing = Mailing.new :text => @mailing.text
    @study.save
    redirect_to edit_study_mailing_path(@study, @study.mailing), :notice => I18n.t('mailings.messages.loaded')
  end

  def update
    @mailing = Mailing.find(params[:id])

    params[:mailing].each {|key, value| @mailing[key] = value }
    if send_testmail(params)

      flash[:notice] = t('mailings.messages.testmail_send')
      render :action => :edit
    elsif @mailing.save
      redirect_to study_url(@study), :notice => t('mailings.messages.saved')
    else
      render :action => :edit
    end
  end

  protected

    def load_study
      @study = Study.find(params[:study_id])
      p @study
    end

    def create_study
      @mailing = Mailing.new(params[:mailing])
    end

    def load_mailing_for_new
      if (@study.mailing_defined?)
        @mailing = @study.mailing
      else
        @mailing = Mailing.new
      end
    end

    def load_mailing_for_load
      @mailing = Mailing.find(params[:mailing])
    end

    def send_testmail(params)
      if params[:testmail]
        user = @study.moderator
        user.password = "p4s$w0rd"
        if @study.mailing
          UserMailer.new_participant_from_mailing(user, @study.mailing, @study.moderator.email).deliver
        else
          UserMailer.new_participant(user, @study.moderator.email).deliver
        end
        true
      end
    end

    def check_study_status
      #TODO: test this switch
      if @study.is_activated?
        flash[:alert] = I18n.t('mailings.messages.study_already_activated')
        redirect_to study_url(study)
      end
    end
end
