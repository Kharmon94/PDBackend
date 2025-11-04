class Business < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :saved_deals, dependent: :destroy
  has_many :saved_by_users, through: :saved_deals, source: :user
  has_many :analytics, dependent: :destroy
  
  validates :name, presence: true
  validates :category, presence: true
  validates :address, presence: true
  validates :rating, numericality: { in: 0..5 }
  validates :review_count, numericality: { greater_than_or_equal_to: 0 }
  validates :approval_status, inclusion: { in: %w[pending approved rejected] }
  
  scope :featured, -> { where(featured: true) }
  scope :with_deals, -> { where(has_deals: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :pending_approval, -> { where(approval_status: 'pending') }
  scope :approved, -> { where(approval_status: 'approved') }
  
  def increment_view_count!
    analytics.create!(event_type: 'view', event_data: { timestamp: Time.current })
  end
  
  def increment_click_count!(click_type)
    analytics.create!(event_type: 'click', event_data: { click_type: click_type, timestamp: Time.current })
  end
  
  def weekly_views
    analytics.where(event_type: 'view', created_at: 1.week.ago..Time.current).count
  end
  
  def weekly_clicks
    analytics.where(event_type: 'click', created_at: 1.week.ago..Time.current).count
  end
end
