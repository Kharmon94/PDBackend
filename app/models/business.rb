class Business < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :saved_deals, dependent: :destroy
  has_many :saved_by_users, through: :saved_deals, source: :user
  has_many :analytics, dependent: :destroy
  
  # Active Storage attachments
  has_one_attached :image
  has_many_attached :gallery_images
  
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
  
  # Clear cache when business is created/updated/deleted
  after_commit :clear_cache
  
  # Full-text search across name, description, category, address, and deals
  scope :search_full_text, ->(query) {
    return all if query.blank?
    
    sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)
    
    where(
      "to_tsvector('english', coalesce(name, '') || ' ' || 
       coalesce(description, '') || ' ' || 
       coalesce(category, '') || ' ' || 
       coalesce(address, '') || ' ' || 
       coalesce(deal_description, '')) @@ plainto_tsquery('english', ?)",
      query
    ).order(
      Arel.sql("ts_rank(to_tsvector('english', coalesce(name, '') || ' ' || 
                coalesce(description, '') || ' ' || 
                coalesce(category, '') || ' ' || 
                coalesce(address, '') || ' ' || 
                coalesce(deal_description, '')), 
                plainto_tsquery('english', '#{sanitized_query}')) DESC")
    )
  }
  
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
  
  # Helper method to get image URL (Active Storage or fallback to image_url)
  def image_url_or_attached
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      image_url
    end
  end
  
  # Helper method to get gallery URLs (Active Storage or fallback to gallery JSON)
  def gallery_urls
    if gallery_images.attached?
      gallery_images.map { |img| Rails.application.routes.url_helpers.rails_blob_path(img, only_path: true) }
    elsif gallery.present? && gallery.is_a?(Array)
      gallery
    else
      []
    end
  end
  
  private
  
  def clear_cache
    # Clear all business-related caches when any business changes
    Rails.cache.delete_matched("businesses/*")
    Rails.cache.delete_matched("autocomplete/*")
  rescue => e
    # Don't let cache clearing errors break the app
    Rails.logger.error "Failed to clear cache: #{e.message}"
  end
end
