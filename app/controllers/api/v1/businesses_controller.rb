class Api::V1::BusinessesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :track_click]
  before_action :authenticate_user!, only: [:create, :update, :destroy, :my_businesses]
  before_action :set_business, only: [:show, :update, :destroy]
  
  def index
    businesses = Business.includes(:user)
    
    # Filter by category
    businesses = businesses.by_category(params[:category]) if params[:category].present?
    
    # Filter by search query
    if params[:search].present?
      businesses = businesses.where(
        "name ILIKE ? OR description ILIKE ?", 
        "%#{params[:search]}%", 
        "%#{params[:search]}%"
      )
    end
    
    # Filter by featured
    businesses = businesses.featured if params[:featured] == 'true'
    
    # Filter by deals
    businesses = businesses.with_deals if params[:deals] == 'true'
    
    render json: businesses.map { |business| business_json(business) }
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
    if @business.update(business_params)
      render json: business_json(@business)
    else
      render json: { errors: @business.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @business.destroy
    head :no_content
  end
  
  def my_businesses
    businesses = current_user.businesses
    render json: businesses.map { |business| business_json(business) }
  end
  
  def analytics
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
