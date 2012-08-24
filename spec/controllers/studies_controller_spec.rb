require 'spec_helper'

describe StudiesController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:moderator) { FactoryGirl.create(:moderator) }
  let(:study) { FactoryGirl.create(:study) }
  let(:own_study) { FactoryGirl.create(:study, :moderator => moderator) }

  context "if user is logged out" do
    it "he can't reach studies#show" do
      get :show, :id => study.id
      response.status.should be 302
      response.location.should eql root_url
    end
  end

  context "if moderator of study" do
    before do
      login moderator
    end

    context "is looking on own study" do
      it "he can reach studies#show" do
        get :show, :id => own_study.id
        response.status.should be 200
      end
    end

    context "is looking on another moderators study" do
      it "he can't reach studies#show" do
        get :show, :id => study.id
        response.status.should be 302
        response.location.should eql root_url
      end
    end
  end

end
