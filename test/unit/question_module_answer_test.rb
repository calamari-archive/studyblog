require 'test_helper'

class QuestionModuleAnswerTest < ActiveSupport::TestCase
  setup do
    @topic = Topic.new :title => "Working dummy topic"
    @question1 = QuestionModule.new :possible_answers => "dummy"
    @question1.question_type = 'likert'
    @question1.left_extreme  = "most left"
    @question1.right_extreme = "most right"
    @question1.number_steps = 5
    @topic.module = @question
    @question1.save

    @question2 = QuestionModule.new :possible_answers => "dummy\nweiter\ngut"
    @question2.question_type = 'likert'
    @question2.left_extreme  = "most left"
    @question2.right_extreme = "most right"
    @question2.number_steps = 5
    @topic.module = @question
    @question2.save
  end

  test "likert can save when answered" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question1
    answer.answers = [1]
    assert answer.valid?
  end

  test "likert can't save empty answer" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question1
    answer.answers = []
    assert !answer.valid?
  end

  test "likert can't save if only some adjectives are answered" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = [1]
    assert !answer.valid?
  end

  test "likert can't save if only to many?!? adjectives are answered" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = [1,3,4,5]
    assert !answer.valid?
  end

  test "likert can save when everything is answerd" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = [1,3,5]
    assert answer.valid?
  end

  test "likert: answers is saved comma separated" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = [1,2,1]
    assert_equal '1,2,1', answer.answers
  end

  test "likert: answer as hash resolves to array" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = { 1=>1, 2=>2, 3=>1 }
    assert_equal '1,2,1', answer.answers
  end

  test "likert: answer as unsorted hash sorts array and then resolves to array" do
    answer = QuestionModuleAnswer.new
    answer.question_module = @question2
    answer.answers = { 1=>1, 3=>2, 2=>1 }
    assert_equal '1,1,2', answer.answers
  end
end
