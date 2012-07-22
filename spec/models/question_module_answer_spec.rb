require 'spec_helper'

describe QuestionModuleAnswer do
  describe '.permitted_to_read?' do
    before do
      group = FactoryGirl.create(:group)
      topic = FactoryGirl.create(:topic, :group => group)
      @question = FactoryGirl.create(:free_text_question, :topic => topic)
      @current_user = FactoryGirl.create(:participant, :group => group)
      @current_user.create_blog

      @another_user = FactoryGirl.create(:participant, :group => group)
      @another_user.create_blog
      another_entry = FactoryGirl.create(:blog_entry, :author => @another_user)
      @another_answer = FactoryGirl.create(:free_text_answer, :question_module_id => @question.id, :blog_entry => another_entry)
    end

    context 'if current_user did fill out same module' do
      before do
        his_entry = FactoryGirl.create(:blog_entry, :author => @current_user)
        @his_answer = FactoryGirl.create(:free_text_answer, :question_module_id => @question.id, :blog_entry => his_entry)
      end

      it 'he can see the other one' do
        @question.permitted_to_read?(@current_user).should be true
      end
    end

    context 'if current_user did not fill out same module' do
      it 'he cannot see the other one' do
        @question.permitted_to_read?(@current_user).should be false
      end
    end

    context 'if current_user is admin' do
      before do
        @current_user.role = 'admin'
      end

      it 'he can see it' do
        @question.permitted_to_read?(@current_user).should be true
      end
    end

    context 'if current_user is moderator' do
      before do
        @current_user.role = 'moderator'
      end

      it 'he can see it' do
        @question.permitted_to_read?(@current_user).should be true
      end
    end

    context 'if current_user is spectator' do
      before do
        @current_user.role = 'spectator'
      end

      it 'he can see it' do
        @question.permitted_to_read?(@current_user).should be true
      end
    end
  end

  describe '.permitted_to_write?' do
    before do
      group = FactoryGirl.create(:group)
      @topic = FactoryGirl.create(:topic, :group => group)
      @question = FactoryGirl.create(:free_text_question, :topic => @topic)
      @current_user = FactoryGirl.create(:participant, :group => group)
      @current_user.create_blog
    end

    context 'if question is in same group' do
      it 'he can answer it' do
        @question.permitted_to_write?(@current_user).should be true
      end
    end

    context 'if question is from another group' do
      before do
        @topic.group = FactoryGirl.create(:group)
        @question = FactoryGirl.create(:free_text_question, :topic => @topic)
      end

      it 'he cannot answer' do
        @question.permitted_to_write?(@current_user).should be false
      end
    end

    context 'if current_user is admin' do
      before do
        @current_user.role = 'admin'
      end

      it 'he cannot write something' do
        @question.permitted_to_write?(@current_user).should be false
      end
    end

    context 'if current_user is moderator' do
      before do
        @current_user.role = 'moderator'
      end

      it 'he cannot write something' do
        @question.permitted_to_write?(@current_user).should be false
      end
    end

    context 'if current_user is spectator' do
      before do
        @current_user.role = 'spectator'
      end

      it 'he cannot write something' do
        @question.permitted_to_write?(@current_user).should be false
      end
    end
  end
end
