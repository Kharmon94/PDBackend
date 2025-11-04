class WhiteLabel < ApplicationRecord
  belongs_to :user
  
  validates :brand_name, presence: true
  validates :subdomain, uniqueness: true, allow_nil: true
  validates :domain, uniqueness: true, allow_nil: true
  
  # Default settings structure
  after_initialize :set_default_settings, if: :new_record?
  
  private
  
  def set_default_settings
    self.settings ||= {
      enable_community_accounts: true,
      enable_save_deals: true,
      enable_messages: false,
      custom_categories: [],
      header_menu: [],
      footer_menu: []
    }
  end
end

