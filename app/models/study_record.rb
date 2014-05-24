class StudyRecord < ActiveRecord::Base

  attr_accessible :study_id, :course_id, :course_item_id, :user_id, :day, :stage, :created_at, :content, :phase, :wrong, :try_id

  belongs_to :user
  belongs_to :study
  belongs_to :course_item
  belongs_to :course

  def wrong?
    return self.wrong
  end

  scope :wrong, -> {joins(:course_item).where(:wrong => 1, :stage => 3).select("COUNT(study_records.id) as cnt, study_records.*").group("course_item_id").order("cnt DESC")}
  scope :wrong_by_course, -> {joins(:course).where(:wrong => 1, :stage => 3).select("COUNT(study_records.id) as cnt, study_records.*").group("course_id").order("cnt DESC")}

end
