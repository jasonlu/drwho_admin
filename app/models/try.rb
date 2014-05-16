class Try < ActiveRecord::Base
  attr_accessible :user_id, :course_id, :study_id, :day, :stage, :phase, :score
  belongs_to :study
  has_many :study_records
  has_many :records, :foreign_key => 'try_id', :class_name => 'StudyRecord'
  #before_create :set_id

private

  def set_id
    self.id = SecureRandom.uuid
  end

  def initialize(attributes = {})
    super

    self.id = SecureRandom.uuid
  end


end
