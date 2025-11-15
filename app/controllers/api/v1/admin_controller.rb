class Api::V1::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_access

  # GET /api/v1/admin/stats
  def stats
    stats = {
      total_users: User.count,
      total_businesses: Business.count,
      total_partners: User.where(user_type: 'partner').count,
      total_distribution_partners: User.where(user_type: 'distribution').count,
      total_admins: User.where(user_type: 'admin').count,
      featured_businesses: Business.where(featured: true).count,
      businesses_with_deals: Business.where(has_deals: true).count,
      total_saved_deals: SavedDeal.count,
      recent_signups: User.where('created_at >= ?', 7.days.ago).count,
      recent_businesses: Business.where('created_at >= ?', 7.days.ago).count,
      pending_approvals: Business.where(approval_status: 'pending').count
    }
    
    render json: stats
  end

  # GET /api/v1/admin/users
  def users
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 25).to_i
    search = params[:search]
    user_type = params[:user_type]

    users = User.order(created_at: :desc)
    users = users.where('name ILIKE ? OR email ILIKE ?', "%#{search}%", "%#{search}%") if search.present?
    users = users.where(user_type: user_type) if user_type.present?
    
    total_count = users.count
    total_pages = (total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    users = users.limit(per_page).offset(offset)

    render json: {
      users: users.map { |user| user_json(user) },
      pagination: {
        current_page: page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end

  # GET /api/v1/admin/businesses
  def businesses
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 25).to_i
    search = params[:search]
    category = params[:category]
    featured = params[:featured]

    businesses = Business.includes(:user).order(created_at: :desc)
    
    if search.present?
      businesses = businesses.where(
        'name ILIKE ? OR description ILIKE ?', 
        "%#{search}%", 
        "%#{search}%"
      )
    end
    
    businesses = businesses.by_category(category) if category.present?
    businesses = businesses.featured if featured == 'true'
    
    total_count = businesses.count
    total_pages = (total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    businesses = businesses.limit(per_page).offset(offset)

    render json: {
      businesses: businesses.map { |business| business_json(business) },
      pagination: {
        current_page: page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end

  # PATCH /api/v1/admin/businesses/:id/feature
  def toggle_featured
    business = Business.find(params[:id])
    business.update!(featured: !business.featured)
    
    render json: { 
      message: "Business #{business.featured ? 'featured' : 'unfeatured'} successfully",
      business: business_json(business)
    }
  end

  # DELETE /api/v1/admin/users/:id
  def destroy_user
    user = User.find(params[:id])
    
    if user.id == current_user.id
      render json: { error: 'Cannot delete your own account' }, status: :unprocessable_entity
      return
    end

    user.destroy
    render json: { message: 'User deleted successfully' }
  end

  # DELETE /api/v1/admin/businesses/:id
  def destroy_business
    business = Business.find(params[:id])
    business.destroy
    render json: { message: 'Business deleted successfully' }
  end

  # GET /api/v1/admin/pending_approvals
  def pending_approvals
    businesses = Business.pending_approval.includes(:user).order(created_at: :desc)
    
    render json: {
      businesses: businesses.map { |business| business_json(business) },
      count: businesses.count
    }
  end

  # PATCH /api/v1/admin/businesses/:id/approve
  def approve_business
    business = Business.find(params[:id])
    business.update!(
      approval_status: 'approved',
      approved_at: Time.current,
      approved_by: current_user
    )
    
    render json: { 
      message: 'Business approved successfully',
      business: business_json(business)
    }
  end

  # PATCH /api/v1/admin/businesses/:id/reject
  def reject_business
    business = Business.find(params[:id])
    business.update!(approval_status: 'rejected')
    
    render json: { message: 'Business rejected' }
  end

  # PATCH /api/v1/admin/users/:id/suspend
  def suspend_user
    user = User.find(params[:id])
    
    if user.id == current_user.id
      render json: { error: 'Cannot suspend your own account' }, status: :unprocessable_entity
      return
    end
    
    user.suspend!(current_user)
    render json: { 
      message: 'User suspended successfully',
      user: user_json(user)
    }
  end

  # PATCH /api/v1/admin/users/:id/activate
  def activate_user
    user = User.find(params[:id])
    user.activate!
    
    render json: { 
      message: 'User activated successfully',
      user: user_json(user)
    }
  end

  private
  
  def check_admin_access
    authorize! :manage, :admin_panel
  end

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      user_type: user.user_type,
      created_at: user.created_at,
      businesses_count: user.businesses.count,
      saved_deals_count: user.saved_deals.count,
      suspended: user.suspended,
      suspended_at: user.suspended_at
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
      created_at: business.created_at,
      user: {
        id: business.user.id,
        name: business.user.name,
        user_type: business.user.user_type
      }
    }
  end
end

