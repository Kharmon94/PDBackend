class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_type, inclusion: { in: %w[user partner distribution admin] }
  
  has_many :businesses, dependent: :destroy
  has_many :saved_deals, dependent: :destroy
  has_many :saved_businesses, through: :saved_deals, source: :business
  belongs_to :suspended_by, class_name: 'User', optional: true
  has_one :white_label, dependent: :destroy
  
  scope :active, -> { where(suspended: false) }
  scope :suspended, -> { where(suspended: true) }
  
  def admin?
    user_type == 'admin'
  end
  
  def partner?
    user_type == 'partner'
  end
  
  def distribution?
    user_type == 'distribution'
  end
  
  def active?
    !suspended
  end
  
  def suspend!(suspended_by_user)
    update!(
      suspended: true,
      suspended_at: Time.current,
      suspended_by: suspended_by_user
    )
  end
  
  def activate!
    update!(
      suspended: false,
      suspended_at: nil,
      suspended_by_id: nil
    )
  end
end
