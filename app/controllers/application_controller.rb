class ApplicationController < ActionController::API
  include ActionController::Cookies
  include CanCan::ControllerAdditions
  
  before_action :authenticate_user!, except: [:login, :signup]
  
  # CanCanCan error handling
  rescue_from CanCan::AccessDenied do |exception|
    render json: { 
      error: 'Access denied', 
      message: exception.message 
    }, status: :forbidden
  end
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        user_id = decoded_token[0]['user_id']
        @current_user = User.find(user_id)
        
        # Check if user is suspended
        if @current_user.suspended?
          render json: { 
            error: 'Account suspended', 
            message: 'Your account has been suspended. Please contact support.' 
          }, status: :forbidden
          return
        end
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Token required' }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user
  end
  
  def generate_token(user)
    JWT.encode({ user_id: user.id }, Rails.application.secret_key_base, 'HS256')
  end
end
