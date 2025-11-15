class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/users/profile
  def profile
    render json: user_json(current_user)
  end

  # PATCH /api/v1/users/profile
  def update_profile
    if current_user.update(profile_params)
      render json: {
        user: user_json(current_user),
        message: 'Profile updated successfully'
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/users/password
  def update_password
    if current_user.authenticate(params[:current_password])
      if current_user.update(password: params[:new_password])
        render json: { message: 'Password updated successfully' }
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Current password is incorrect' }, status: :unauthorized
    end
  end

  # DELETE /api/v1/users/account
  def destroy_account
    # Require password confirmation for security
    if current_user.authenticate(params[:password])
      current_user.destroy
      render json: { message: 'Account deleted successfully' }
    else
      render json: { error: 'Password incorrect' }, status: :unauthorized
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def user_json(user)
    # Get avatar URL from Active Storage if attached
    # Rails will automatically generate S3 signed URLs in production or local routes in development
    avatar_url = if user.avatar.attached?
      begin
        if Rails.env.production?
          # S3: url_for automatically generates signed S3 URL
          url_for(user.avatar)
        else
          # Local: use rails_blob_url with request host for full URL
          host = "#{request.protocol}#{request.host_with_port}"
          Rails.application.routes.url_helpers.rails_blob_url(user.avatar, host: host)
        end
      rescue => e
        Rails.logger.error "Failed to generate avatar URL: #{e.message}"
        nil
      end
    else
      nil
    end
    
    {
      id: user.id,
      name: user.name,
      email: user.email,
      user_type: user.user_type,
      avatar: avatar_url,
      created_at: user.created_at,
      businesses_count: user.businesses.count,
      saved_deals_count: user.saved_deals.count
    }
  end
end

