require 'spec_helper'

describe MailingsController do
  # all_actions = %w{show new edit create save update load}

  let(:admin) { FactoryGirl.create(:admin) }
  let(:moderator) { FactoryGirl.create(:moderator) }
  let(:study) { FactoryGirl.create(:study) }
  let(:own_study) { FactoryGirl.create(:study, :moderator => moderator) }
  let(:mailing) { FactoryGirl.create(:mailing, :study => study) }
  let(:own_mailing) { FactoryGirl.create(:mailing, :study => own_study) }

  let(:participant) { FactoryGirl.create(:participant) }

  context "if user is logged out" do
    it "can't reach mailings#show" do
      get :show, :id => mailing.id, :study_id => study.id
      should_access_deny(response)
    end

    it "can't reach mailings#edit" do
      get :edit, :id => mailing.id, :study_id => study.id
      should_access_deny(response)
    end

    it "can't reach mailings#new" do
      get :new, :study_id => study.id
      should_access_deny(response)
    end

    it "can't reach mailings#create" do
      post :create, :study_id => study.id, :mailing => { :text => 'lala' }
      should_access_deny(response)
    end

    it "can't reach GET mailings#save" do
      get :save, :id => mailing.id
      should_access_deny(response)
    end

    it "can't reach POST mailings#save" do
      post :save, :id => mailing.id
      should_access_deny(response)
    end

    it "can't reach mailings#load" do
      post :load, :id => own_mailing.id, :study_id => study.id
      should_access_deny(response)
    end

    it "can't reach mailings#update" do
      put :update, :id => mailing.id, :study_id => study.id
      should_access_deny(response)
    end
  end

  context "if user is an admin" do
    context "and not a moderator of this study" do
      before do
        login admin
      end

      it "can't reach mailings#show" do
        get :show, :id => mailing.id, :study_id => study.id
        should_access_deny(response)
      end

      it "can't reach mailings#edit" do
        get :edit, :id => mailing.id, :study_id => study.id
        should_access_deny(response)
      end

      it "can't reach mailings#new" do
        get :new, :study_id => study.id
        should_access_deny(response)
      end

      it "can't reach mailings#create" do
        post :create, :study_id => study.id, :mailing => { :text => 'lala' }
        should_access_deny(response)
      end

      it "can't reach GET mailings#save" do
        get :save, :id => mailing.id
        should_access_deny(response)
      end

      it "can't reach POST mailings#save" do
        post :save, :id => mailing.id
        should_access_deny(response)
      end

      it "can't reach mailings#load" do
        post :load, :id => own_mailing.id, :study_id => study.id
        should_access_deny(response)
      end

      it "can't reach mailings#update" do
        put :update, :id => mailing.id, :study_id => study.id
        should_access_deny(response)
      end
    end

    context "and moderator of this study" do
      before do
        own_study.moderator = admin
        own_study.save!
        login admin
      end

      it "can reach mailings#show" do
        get :show, :id => own_mailing.id
        should_access_allow(response)
      end

      it "can reach mailings#edit" do
        get :edit, :id => own_mailing.id
        should_access_allow(response)
      end

      it "can reach mailings#new" do
        p admin.id
        get :new, :study_id => own_study.id
        should_access_allow(response)
      end

      it "can reach mailings#create" do
        post :create, :study_id => own_study.id, :mailing => { :text => 'lala' }
        should_access_allow(response)
      end
    end
  end
end
