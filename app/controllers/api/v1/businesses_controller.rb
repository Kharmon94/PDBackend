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
      :image, gallery_images: [],
      hours: {}, amenities: [], gallery: []
    )
  end
  
  def business_json(business)
    # Get image URL from Active Storage or fallback to image_url
    # Rails will automatically generate S3 signed URLs in production or local routes in development
    image_url = if business.image.attached?
      begin
        # Use url_for which Rails handles automatically (S3 signed URLs in production, local routes in dev)
        # For local storage, we need to provide the host
        if Rails.env.production?
          # S3: url_for automatically generates signed S3 URL
          url_for(business.image)
        else
          # Local: use rails_blob_url with request host for full URL
          host = "#{request.protocol}#{request.host_with_port}"
          Rails.application.routes.url_helpers.rails_blob_url(business.image, host: host)
        end
      rescue => e
        Rails.logger.error "Failed to generate image URL: #{e.message}"
        business.image_url
      end
    else
      business.image_url
    end
    
    # Get gallery URLs from Active Storage or fallback to gallery JSON
    gallery_urls = if business.gallery_images.attached?
      host = Rails.env.production? ? nil : "#{request.protocol}#{request.host_with_port}"
      business.gallery_images.map do |img|
        begin
          if Rails.env.production?
            # S3: url_for automatically generates signed S3 URL
            url_for(img)
          else
            # Local: use rails_blob_url with request host for full URL
            Rails.application.routes.url_helpers.rails_blob_url(img, host: host)
          end
        rescue => e
          Rails.logger.error "Failed to generate gallery image URL: #{e.message}"
          nil
        end
      end.compact
    elsif business.gallery.present? && business.gallery.is_a?(Array)
      business.gallery
    else
      []
    end
    
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
      image: image_url,
      featured: business.featured,
      has_deals: business.has_deals,
      deal: business.deal_description,
      hours: business.hours,
      amenities: business.amenities,
      gallery: gallery_urls,
      user: {
        id: business.user.id,
        name: business.user.name
      }
    }
  end
end
