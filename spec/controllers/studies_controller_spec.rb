require 'spec_helper'

describe StudiesController do
  context "Permissions" do
    all_actions = %w{show index new create update destroy} # with id parameter

    let(:admin) { FactoryGirl.create(:admin) }
    let(:moderator) { FactoryGirl.create(:moderator) }
    let(:study) { FactoryGirl.create(:study) }
    let(:own_study) { FactoryGirl.create(:study, :moderator => moderator) }

    context "if user is logged out" do
      all_actions.each do |action|
        it "can't reach studies##{action}" do
          get action.to_sym, :id => own_study.id
          should_access_deny(response)
        end
      end

      it "he can't reach studies#assign" do
        get :assign, :study_id => study.id
        should_access_deny(response)
      end

      it "he can't reach studies#activate" do
        get :activate, :study_id => study.id
        should_access_deny(response)
      end
    end

    context "an admin" do
      before do
        login admin
      end

      context "looking on a study" do
        it "can reach studies#show" do
          get :show, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#index" do
          get :index, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#new" do
          get :new, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#create" do
          get :create, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#update" do
          get :update, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#destroy" do
          get :destroy, :id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#assign" do
          get :assign, :study_id => study.id
          should_access_allow(response)
        end

        it "he can't reach studies#activate" do
          get :activate, :study_id => study.id
          should_access_allow(response)
        end
      end
    end

    context "moderator" do
      before do
        login moderator
      end

      context "looking on own study" do
        all_actions.each do |action|
          it "can't reach studies##{action}" do
            get action.to_sym, :id => own_study.id
            should_access_allow(response)
          end
        end

        it "can't reach studies#assign" do
          get :assign, :study_id => own_study.id
          should_access_deny(response)
        end

        it "can reach studies#activate" do
          get :activate, :study_id => own_study.id
          should_access_allow(response)
        end
      end

      context "looking on another moderators study" do
        all_actions.each do |action|
          it "can't reach studies##{action}" do
            get action.to_sym, :id => study.id
            should_access_deny(response)
          end
        end

        it "he can't reach studies#assign" do
          get :assign, :study_id => study.id
          should_access_deny(response)
        end

        it "he can't reach studies#activate" do
          get :activate, :study_id => study.id
          should_access_deny(response)
        end
      end
    end

    context "participant" do
     let(:group) { FactoryGirl.create(:group, :study => own_study) }
     let(:participant) { FactoryGirl.create(:participant, :group => group) }
      before do
        login participant
      end

      context "looking on study he is part of" do
        all_actions.each do |action|
          it "can't reach studies##{action}" do
            get action.to_sym, :id => own_study.id
            should_access_deny(response)
          end
        end

        it "he can't reach studies#assign" do
          get :assign, :study_id => own_study.id
          should_access_deny(response)
        end

        it "he can't reach studies#activate" do
          get :activate, :study_id => own_study.id
          should_access_deny(response)
        end
      end

      context "looking on totally different study" do
        all_actions.each do |action|
          it "can't reach studies##{action}" do
            get action.to_sym, :id => study.id
            should_access_deny(response)
          end
        end

        it "he can't reach studies#assign" do
          get :assign, :study_id => study.id
          should_access_deny(response)
        end

        it "he can't reach studies#activate" do
          get :activate, :study_id => study.id
          should_access_deny(response)
        end
      end
    end

    context "spectator of study" do
     let(:group) { FactoryGirl.create(:group, :study => own_study) }
     let(:spectator) { FactoryGirl.create(:spectator, :group => group) }
      before do
        login spectator
      end

      context "looking on a study" do
        all_actions.each do |action|
          it "can't reach studies##{action}" do
            get action.to_sym, :id => own_study.id
            should_access_deny(response)
          end
        end

        it "he can't reach studies#assign" do
          get :assign, :study_id => own_study.id
          should_access_deny(response)
        end

        it "he can't reach studies#activate" do
          get :activate, :study_id => own_study.id
          should_access_deny(response)
        end
      end
    end
  end
end
