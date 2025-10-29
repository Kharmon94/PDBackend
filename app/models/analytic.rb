class Analytic < ApplicationRecord
  belongs_to :business
  
  validates :event_type, presence: true
  validates :event_type, inclusion: { in: %w[view click phone email website] }
end
