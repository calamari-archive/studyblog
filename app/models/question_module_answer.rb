class QuestionModuleAnswer < ActiveRecord::Base
  belongs_to :question_module
  has_one :blog_entry, :as => :module_answer
  has_one :author, :through => :blog_entry

  validates_presence_of :answers
  validate :check_answer

  attr_accessible :answers

  def answers=(val)
    if is_likert
      if val.class != Array
        val = val.sort.map {|i| val[i[0]] }
      end
      write_attribute(:answers, val.join(','))
    else
      write_attribute(:answers, val)
    end
  end

  def answer_array
    answers.split(',')
  end

  def is_likert
    question_module.question_type == 'likert'
  end

private
  def check_answer
    if self.answers.nil? || self.answers.empty? || (is_likert && self.question_module.possible_answers.count != self.answers.split(',').count)
      errors.add(:answers, I18n.t('modules.question.errors.likert.answers'))
    end
  end
end
