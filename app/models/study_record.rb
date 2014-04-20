class StudyRecord < ActiveRecord::Base
  attr_accessible :study_id, :course_id, :course_item_id, :user_id, :day, :stage, :created_at, :content, :phase, :wrong
  belongs_to :user
  belongs_to :study
  belongs_to :course_item
  belongs_to :course

  def wrong?
    return self.wrong
  end

end
