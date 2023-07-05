class Users::RegistrationsController < Devise::RegistrationsController
  
  skip_before_action :verify_authenticity_token

  def create
    if params[:data] && params[:data][:type] == "sms_account"
      build_resource(sign_up_params)
      resource.save
      if resource.persisted?
        if resource.active_for_authentication?
          # Twilio::SmsService.new(to: resource.full_phone_number, pin: '').send_otp
          sign_up(resource_name, resource)
          token = request.env['warden-jwt_auth.token']
          render json: {
            id: resource.id, 
            type: "sms-otp",
            attributes: {
              pin: 1111
            },
            meta: {
              token: token
            },
            message: 'User created successfully'  }, status: 200
        else
          render json: { status: { code: 401, message: "User is not active" } }
        end
      else
        existing_user = User.find_by(email: resource.email)
        if  existing_user
          if existing_user.academic.present?
            render json: {
              id: existing_user&.id, 
              type: "sms-otp",
              meta: { token: token },
              message: "Account already exists"  
            }, status: 200
          else
            existing_user.full_phone_number = params[:data][:user][:full_phone_number]
            token = existing_user.generate_jwt
            # Twilio::SmsService.new(to:existing_user.full_phone_number, pin: '').send_otp
            render json: {
              id: existing_user&.id, 
              meta: { token: token },
              message: "Account already exists, Verification code has been sent on your phone number, Please verify your phone number number to activate your account"
            }, status: 200
          end
        else
          render status: 422, json: {errors: resource.errors.full_messages}
        end          
      end
    else
      render json: { status: { code: 400, message: "Invalid account type" } }
    end
  end

  private

  def sign_up_params
    params.require(:data).require(:user).permit(:first_name, :last_name, :full_phone_number, :email, :gender, :role, :date_of_birth, :country, :city, :state, :address, :password, :password_confirmation)
  end
end