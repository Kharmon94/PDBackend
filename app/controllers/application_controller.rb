class ApplicationController < ActionController::API
  include ActionController::Cookies
  
  before_action :authenticate_user!, except: [:login, :signup]
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
        user_id = decoded_token[0]['user_id']
        @current_user = User.find(user_id)
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
