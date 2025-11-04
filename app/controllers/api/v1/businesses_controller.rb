class Api::V1::BusinessesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :track_click, :autocomplete]
  before_action :authenticate_user!, only: [:create, :update, :destroy, :my_businesses, :analytics]
  before_action :set_business, only: [:show, :update, :destroy, :analytics]
  
  # CanCanCan authorization
  load_and_authorize_resource except: [:index, :track_click, :my_businesses, :analytics, :autocomplete]
  
  def index
    # Create cache key from query parameters
    cache_key = ['businesses', params[:search], params[:category], params[:featured], params[:deals], params[:limit]].compact.join('/')
    
    businesses = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      result = Business.includes(:user)
      
      # Full-text search
      result = result.search_full_text(params[:search]) if params[:search].present?
      
      # Filter by category
      result = result.by_category(params[:category]) if params[:category].present?
      
      # Filter by featured
      result = result.featured if params[:featured] == 'true'
      
      # Filter by deals
      result = result.with_deals if params[:deals] == 'true'
      
      # Limit for autocomplete
      result = result.limit(params[:limit].to_i) if params[:limit].present?
      
      result.to_a
    end
    
    render json: businesses.map { |business| business_json(business) }
  end
  
  def autocomplete
    query = params[:query]
    return render json: [] if query.blank? || query.length < 2
    
    # Normalize query for consistent caching
    cache_key = "autocomplete/#{query.downcase.strip}"
    
    suggestions = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      Business.search_full_text(query)
             .limit(10)
             .pluck(:name, :category, :address)
             .map do |name, category, address|
        {
          name: name,
          category: category,
          location: address.split(',').last&.strip
        }
      end
    end
    
    render json: suggestions
  end
  
  def show
    @business.increment_view_count!
    render json: business_json(@business)
  end
  
  def create
    business = current_user.businesses.build(business_params)
    
    if business.save
      render json: business_json(business), status: :created
    else
      render json: { errors: business.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    authorize! :update, @business
    if @business.update(business_params)
      render json: business_json(@business)
    else
      render json: { errors: @business.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize! :destroy, @business
    @business.destroy
    head :no_content
  end
  
  def my_businesses
    businesses = current_user.businesses
    render json: businesses.map { |business| business_json(business) }
  end
  
  def analytics
    authorize! :read, Analytic
    business = current_user.businesses.find(params[:id])
    
    analytics_data = {
      total_views: business.analytics.where(event_type: 'view').count,
      total_clicks: business.analytics.where(event_type: 'click').count,
      weekly_views: business.weekly_views,
      weekly_clicks: business.weekly_clicks,
      phone_clicks: business.analytics.where(event_type: 'click', event_data: { click_type: 'phone' }).count,
      email_clicks: business.analytics.where(event_type: 'click', event_data: { click_type: 'email' }).count,
      website_clicks: business.analytics.where(event_type: 'click', event_data: { click_type: 'website' }).count
    }
    
    render json: analytics_data
  end
  
  def track_click
    business = Business.find(params[:id])
    business.increment_click_count!(params[:click_type])
    head :ok
  end
  
  private
  
  def set_business
    @business = Business.find(params[:id])
  end
  
  def business_params
    params.require(:business).permit(
      :name, :category, :description, :address, :phone, :email, :website,
      :image_url, :featured, :has_deals, :deal_description, :rating, :review_count,
      hours: {}, amenities: [], gallery: []
    )
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
      hours: business.hours,
      amenities: business.amenities,
      gallery: business.gallery,
      user: {
        id: business.user.id,
        name: business.user.name
      }
    }
  end
end
