require 'spec_helper'

describe User do
  context "validation" do
    #TODO test it
  end

  context "attributes" do
    #TODO test it
  end

  context ".get_available_recipients" do
    context "an 'admin'" do
      let!(:admin1) { FactoryGirl.create(:admin) }
      let!(:admin2) { FactoryGirl.create(:admin) }
      let!(:moderator1) { FactoryGirl.create(:moderator) }
      let!(:spectator1) { FactoryGirl.create(:spectator) }
      let!(:participant1) { FactoryGirl.create(:participant) }

      it "does not see himself" do
        admin1.get_available_recipients.should_not include(admin1)
      end

      it "sees other admins" do
        admin1.get_available_recipients.should include(admin2)
      end

      it "sees other moderators" do
        admin1.get_available_recipients.should include(moderator1)
      end

      it "sees other spectators" do
        admin1.get_available_recipients.should include(spectator1)
      end

      it "does not see every participant" do
        admin1.get_available_recipients.should_not include(participant1)
      end
    end

    context "a 'moderator'" do
      let!(:admin1) { FactoryGirl.create(:admin) }

      let!(:moderator1) { FactoryGirl.create(:moderator) }
      let!(:moderator2) { FactoryGirl.create(:moderator) }
      let!(:study_of_mod1) { FactoryGirl.create(:study, :moderator => moderator1) }
      let!(:study_of_mod2) { FactoryGirl.create(:study, :moderator => moderator2) }
      let!(:group_of_mod1) { FactoryGirl.create(:group, :study => study_of_mod1) }
      let!(:group_of_mod2) { FactoryGirl.create(:group, :study => study_of_mod2) }

      let!(:spectator1) { FactoryGirl.create(:spectator, :group => group_of_mod1) }
      let!(:spectator2) { FactoryGirl.create(:spectator, :group => group_of_mod2) }
      let!(:participant1) { FactoryGirl.create(:participant, :group => group_of_mod1) }
      let!(:participant2) { FactoryGirl.create(:participant, :group => group_of_mod2) }
      let!(:inactive_participant) { FactoryGirl.create(:participant, :group => group_of_mod1, :active => false, :nickname => nil) }

      it "does not see himself" do
        moderator1.get_available_recipients.should_not include(moderator1)
      end

      it "does not see other moderators" do
        moderator1.get_available_recipients.should_not include(moderator2)
      end

      it "sees admins" do
        moderator1.get_available_recipients.should include(admin1)
      end

      it "does not see spectators of alien groups" do
        moderator1.get_available_recipients.should_not include(spectator2)
      end

      it "sees participants of his own groups" do
        moderator1.get_available_recipients.should include(participant1)
      end

      it "does not see participants of alien groups" do
        moderator1.get_available_recipients.should_not include(participant2)
      end

      it "does not see participants that were never logged in" do
        moderator1.get_available_recipients.should_not include(inactive_participant)
      end
    end

    context "a 'spectator'" do
      let!(:admin1) { FactoryGirl.create(:admin) }

      let!(:moderator1) { FactoryGirl.create(:moderator) }
      let!(:moderator2) { FactoryGirl.create(:moderator) }
      let!(:study_of_mod1) { FactoryGirl.create(:study, :moderator => moderator1) }
      let!(:study_of_mod2) { FactoryGirl.create(:study, :moderator => moderator2) }
      let!(:group_of_mod1) { FactoryGirl.create(:group, :study => study_of_mod1) }
      let!(:group_of_mod2) { FactoryGirl.create(:group, :study => study_of_mod2) }

      let!(:spectator1) { FactoryGirl.create(:spectator, :group => group_of_mod1) }
      let!(:spectator2) { FactoryGirl.create(:spectator, :group => group_of_mod1) }
      let!(:participant1) { FactoryGirl.create(:participant, :group => group_of_mod1) }
      let!(:participant2) { FactoryGirl.create(:participant, :group => group_of_mod2) }

      it "does not see himself" do
        spectator1.get_available_recipients.should_not include(spectator1)
      end

      it "does not see other spectators" do
        spectator1.get_available_recipients.should_not include(spectator2)
      end

      it "does not see the admins" do
        spectator1.get_available_recipients.should_not include(admin1)
      end

      it "sees moderators of his own groups" do
        spectator1.get_available_recipients.should include(moderator1)
      end

      it "does not see moderators of alien groups" do
        spectator1.get_available_recipients.should_not include(moderator2)
      end

      it "does not see participants of his own groups" do
        spectator1.get_available_recipients.should_not include(participant1)
      end

      it "does not see participants of alien groups" do
        spectator1.get_available_recipients.should_not include(participant2)
      end
    end

    context "a 'participant'" do
      let!(:admin1) { FactoryGirl.create(:admin) }

      let!(:moderator1) { FactoryGirl.create(:moderator) }
      let!(:moderator2) { FactoryGirl.create(:moderator) }
      let!(:study1) { FactoryGirl.create(:study, :moderator => moderator1) }
      let!(:study2) { FactoryGirl.create(:study, :moderator => moderator1) }
      let!(:group1) { FactoryGirl.create(:group, :study => study1) }
      let!(:group2) { FactoryGirl.create(:group, :study => study1) }
      let!(:group3) { FactoryGirl.create(:group, :study => study2) }

      let!(:spectator1) { FactoryGirl.create(:spectator, :group => group1) }
      let!(:spectator2) { FactoryGirl.create(:spectator, :group => group2) }
      let!(:spectator3) { FactoryGirl.create(:spectator, :group => group3) }
      let!(:participant1) { FactoryGirl.create(:participant, :group => group1) }
      let!(:participant2) { FactoryGirl.create(:participant, :group => group1) }
      let!(:participant3) { FactoryGirl.create(:participant, :group => group2) }
      let!(:participant4) { FactoryGirl.create(:participant, :group => group3) }

      it "does not see himself" do
        participant1.get_available_recipients.should_not include(participant1)
      end

      it "does not see spectators of same group" do
        participant1.get_available_recipients.should_not include(spectator1)
      end

      it "does not see other spectators" do
        participant1.get_available_recipients.should_not include(spectator2)
      end

      it "does not see the admins" do
        participant1.get_available_recipients.should_not include(admin1)
      end

      it "sees the moderators of his own group" do
        participant1.get_available_recipients.should include(moderator1)
      end

      it "does not see moderators of alien groups" do
        participant1.get_available_recipients.should_not include(moderator2)
      end

      it "sees participants of his own groups" do
        participant1.get_available_recipients.should include(participant2)
      end

      it "does not see participants of alien groups but same study" do
        participant1.get_available_recipients.should_not include(participant3)
      end

      it "does not see participants of alien groups of alien study" do
        participant1.get_available_recipients.should_not include(participant4)
      end

      context "if user are not allowed to see eachother" do
        before do
          group1.can_user_see_eachother = false
        end

        it "does not see participants of his own groups" do
          participant1.get_available_recipients.should_not include(participant2)
        end
      end
    end
  end
end
