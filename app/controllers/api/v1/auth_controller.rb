class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [:me, :logout]
  
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = generate_token(user)
      render json: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          user_type: user.user_type
        },
        token: token,
        message: 'Successfully logged in!'
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  
  def signup
    user = User.new(user_params)
    
    if user.save
      token = generate_token(user)
      render json: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          user_type: user.user_type
        },
        token: token,
        message: 'Account created successfully!'
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def me
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        user_type: current_user.user_type
      }
    }
  end
  
  def logout
    render json: { message: 'Successfully logged out!' }
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :user_type)
  end
end
