class Api::V1::SavedDealsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    saved_deals = current_user.saved_deals.includes(:business)
    businesses = saved_deals.map(&:business)
    
    render json: businesses.map { |business| business_json(business) }
  end
  
  def create
    business = Business.find(params[:business_id])
    saved_deal = current_user.saved_deals.build(business: business)
    
    if saved_deal.save
      render json: { message: 'Deal saved successfully!' }
    else
      render json: { errors: saved_deal.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    saved_deal = current_user.saved_deals.find_by(business_id: params[:business_id])
    
    if saved_deal&.destroy
      render json: { message: 'Deal removed successfully!' }
    else
      render json: { error: 'Deal not found' }, status: :not_found
    end
  end
  
  def toggle
    business = Business.find(params[:business_id])
    saved_deal = current_user.saved_deals.find_by(business: business)
    
    if saved_deal
      saved_deal.destroy
      render json: { saved: false, message: 'Deal removed successfully!' }
    else
      current_user.saved_deals.create!(business: business)
      render json: { saved: true, message: 'Deal saved successfully!' }
    end
  end
  
  private
  
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
