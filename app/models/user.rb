class User < ActiveRecord::Base
  
  has_many :user_orders, :dependent => :destroy
  has_many :self_learnings, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :inboxes, :dependent => :destroy
  has_many :messages, through: :inboxes, :dependent => :destroy
  has_many :studies, :dependent => :destroy
  has_many :study_records, :dependent => :destroy
  has_many :progresses, :dependent => :destroy
  has_one :user_profile, :dependent => :destroy
  has_one :profile, :foreign_key => 'user_id', :class_name => 'UserProfile'
  before_create :build_user_profile, :generate_serial_id

  accepts_nested_attributes_for :profile, :user_profile

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :recoverable, :trackable, :validatable, :confirmable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :roles, :remember_me, :user_profile_attributes, :confirmed_at, :confirmation_token

  # attr_accessible :title, :body

  scope :male, -> {joins(:user_profile).where("user_profiles.gender = 1")}
  scope :female, -> {joins(:user_profile).where("user_profiles.gender = 0")}
  scope :birthday_person, -> {joins(:user_profile).where("MONTH(user_profiles.dob) = ?", Time.now.strftime("%-m"))}

  def fullname
    unless self.nil? and self.profile.nil?
      return '' if(self.profile.lastname.blank? || self.profile.firstname.blank?)
      self.profile.lastname + ' ' + self.profile.firstname
    else
      'System Manager'
    end
  end

  def activated
    if self.confirmed_at.blank?
      return false
    else
      return true;
    end
  end

private
  def generate_serial_id

    unless User.last.nil?
      serial_id = User.last.id + 1000065535
      #self.id = User.last.id + 1000 + 1
    else
      serial_id = 1000065535
      #self.id = 1001
    end

    self.serial_id = serial_id
  end
end
