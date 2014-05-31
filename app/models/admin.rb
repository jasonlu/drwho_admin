class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :messages, :foreign_key => 'user_id', :dependent => :destroy
  
  has_one :profile, :foreign_key => 'user_id', :class_name => 'UserProfile', :dependent => :destroy
  has_one :user_profile, :foreign_key => 'user_id', :dependent => :destroy
  accepts_nested_attributes_for :profile, :user_profile

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :roles, :remember_me, :user_profile_attributes, :confirmed_at, :confirmation_token

  
  before_create :build_profile

  ROLES = %w[admin marketing_manager course_manager order_manager user_manager admin_manager]

  def roles=(roles)  #scope :everyone, -> {all}
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end

  def fullname
    if self.profile.nil?
      "NOT SET"
    else
      self.profile.try(:lastname) + ' ' + self.profile.(:firstname)
    end

  end

end
