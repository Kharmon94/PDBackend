class Api::V1::DistributionController < ApplicationController
  before_action :authenticate_user!
  before_action :check_distribution_access

  # GET /api/v1/distribution/dashboard
  def dashboard
    stats = {
      total_businesses: current_user.businesses.count,
      active_deals: current_user.businesses.where(has_deals: true).count,
      total_views: current_user.businesses.joins(:analytics).where(analytics: { event_type: 'view' }).count,
      total_clicks: current_user.businesses.joins(:analytics).where(analytics: { event_type: 'click' }).count,
      featured_businesses: current_user.businesses.where(featured: true).count
    }
    
    render json: stats
  end

  # GET /api/v1/distribution/businesses
  def businesses
    businesses = current_user.businesses.includes(:user, :analytics)
    render json: businesses.map { |business| business_json(business) }
  end

  # GET /api/v1/distribution/white_label
  def get_white_label
    white_label = current_user.white_label || current_user.create_white_label!(brand_name: current_user.name)
    render json: white_label_json(white_label)
  end

  # PATCH /api/v1/distribution/white_label
  def update_white_label
    white_label = current_user.white_label || current_user.create_white_label!(brand_name: current_user.name)
    
    if white_label.update(white_label_params)
      render json: {
        white_label: white_label_json(white_label),
        message: 'White label settings updated successfully'
      }
    else
      render json: { errors: white_label.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/distribution/stats
  def stats
    # Weekly stats for charts
    stats = {
      weekly_views: [],
      weekly_clicks: [],
      total_revenue: 0, # Placeholder for future revenue tracking
      partner_count: 1 # Current user
    }
    
    7.days.ago.to_date.upto(Date.today) do |date|
      views = current_user.businesses.joins(:analytics)
        .where(analytics: { event_type: 'view', created_at: date.beginning_of_day..date.end_of_day })
        .count
      
      clicks = current_user.businesses.joins(:analytics)
        .where(analytics: { event_type: 'click', created_at: date.beginning_of_day..date.end_of_day })
        .count
      
      stats[:weekly_views] << { date: date.strftime('%a'), views: views }
      stats[:weekly_clicks] << { date: date.strftime('%a'), clicks: clicks }
    end
    
    render json: stats
  end

  private

  def check_distribution_access
    authorize! :manage, :distribution
  end

  def white_label_params
    params.require(:white_label).permit(
      :domain, :subdomain, :brand_name, :logo_url, :primary_color, :secondary_color, :custom_css,
      settings: {}
    )
  end

  def white_label_json(white_label)
    {
      id: white_label.id,
      domain: white_label.domain,
      subdomain: white_label.subdomain,
      brand_name: white_label.brand_name,
      logo_url: white_label.logo_url,
      primary_color: white_label.primary_color,
      secondary_color: white_label.secondary_color,
      custom_css: white_label.custom_css,
      settings: white_label.settings
    }
  end

  def business_json(business)
    {
      id: business.id,
      name: business.name,
      category: business.category,
      description: business.description,
      address: business.address,
      phone: business.phone,
      email: business.email,
      website: business.website,
      rating: business.rating,
      review_count: business.review_count,
      image: business.image_url,
      featured: business.featured,
      has_deals: business.has_deals,
      deal: business.deal_description,
      approval_status: business.approval_status,
      created_at: business.created_at,
      updated_at: business.updated_at,
      user: {
        id: business.user.id,
        name: business.user.name
      }
    }
  end
end

