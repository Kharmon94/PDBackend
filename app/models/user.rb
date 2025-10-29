class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_type, inclusion: { in: %w[user partner distribution admin] }
  
  has_many :businesses, dependent: :destroy
  has_many :saved_deals, dependent: :destroy
  has_many :saved_businesses, through: :saved_deals, source: :business
  
  def admin?
    user_type == 'admin'
  end
  
  def partner?
    user_type == 'partner'
  end
  
  def distribution?
    user_type == 'distribution'
  end
end
