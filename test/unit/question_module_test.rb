require 'test_helper'

class QuestionModuleTest < ActiveSupport::TestCase
  setup do
    @topic = Topic.new :title => "Working dummy topic"
    @question = QuestionModule.new :possible_answers => "dummy"
    @question.left_extreme  = "most left"
    @question.right_extreme = "most right"
    @topic.module = @question
  end

  test "free_text needs no config" do
    @question.question_type = 'free_text'
    assert @question.valid?
  end

  test "likert and config validation" do
    @question.question_type = 'likert'
    assert !@question.valid?

    @question.config = "blabla"
    assert !@question.valid?, 'that should not be right'

    @question.config = { :foo => 'bar', 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    assert !@question.valid?, 'still no steps in config'

    @question.config = { 'steps' => 1, 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    assert !@question.valid?, 'steps should be to low'

    @question.config = { 'steps' => 11, 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    assert !@question.valid?, 'steps should be to high'

    @question.config = { 'steps' => 10, 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    assert @question.valid?, 'steps should be right now'

    @question.config = { 'steps' => 3, 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    assert @question.valid?, 'steps should be right now'
  end

  test "config is loaded and saved properly" do
    assert_equal Hash, @question.config.class, 'config should be a Hash after initialization'
    @question.question_type = 'likert'
    @question.config = { 'steps' => 3, 'left_extreme' => 'good', 'right_extreme' => 'bad' }
    @question.save!

    loaded_question = QuestionModule.find(@question.id)
    assert_equal Hash, @question.config.class, 'config should still be a Hash'
    assert_equal Hash, loaded_question.config.class, 'loaded config should be a Hash'
    assert_equal 3, loaded_question.config['steps']
  end

  test "number_steps can be read from config" do
    @question.question_type = 'likert'
    assert_equal 0, @question.number_steps, 'if empty it should be 0'

    @question.config = { 'steps' => 2 }
    assert_equal 2, @question.number_steps
  end

  test "number_steps writes to config" do
    @question.question_type = 'likert'
    assert_equal 0, @question.number_steps, 'if empty it should be 0'

    @question.number_steps = 42
    assert_equal 42, @question.number_steps
    assert_equal 42, @question.config['steps']
  end

  test "likert scale needs a left and a right extreme" do
    @question.question_type = 'likert'
    @question.number_steps = 4

    @question.left_extreme = ""
    @question.right_extreme = ""
    assert !@question.valid?, 'extremes should not be set'
    assert !@question.errors[:left_extreme].empty?, 'left_extreme should not be set'

    @question.left_extreme = "bad"
    assert !@question.valid?, 'extremes should not be set'
    assert @question.errors[:left_extreme].empty?, 'left_extreme should be set'
    assert !@question.errors[:right_extreme].empty?, 'right_extreme should not be set'

    @question.right_extreme = "good"
    assert @question.valid?, 'all should be set now'
  end

  test "likert possible_answers must be a list of different adjectives to answer" do
    @question.question_type = 'likert'
    @question.number_steps = 4
    @question.possible_answers = ""

    assert !@question.valid?, 'possible_answers should be set'
    assert !@question.errors[:possible_answers].empty?, 'possible_answers should be set'

    @question.possible_answers = "Is it?"
  end
end
