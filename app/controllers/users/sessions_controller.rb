class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  include ActionController::Flash

  respond_to :json

  def create
    user = User.find_by(email: params[:user][:email])
    
    if user && user.valid_password?(params[:user][:password])
      if user.role == 'admin'
        sign_in user
        token = request.env['warden-jwt_auth.token']
        render json: {
          user: user,
          token: token
        }, status: 200
      elsif user.academic.present?
        sign_in user
        token = request.env['warden-jwt_auth.token']
        render json: {
          user: user,
          academic: user.academic,
          token: token
        }, status: 200
      else
        render json: {
          message: 'Add academic record to log in'
        }, status: 404
      end
    else
      render json: {
        message: "Invalid password or email"
      }, status: 401
    end
  end
  

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: {code: 200, message: 'Logged in sucessfully.'},
      data: resource
    }
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end