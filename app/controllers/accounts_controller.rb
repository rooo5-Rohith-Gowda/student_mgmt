class AccountsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def otp_verification
     code = Twilio::SmsService.new(to: current_user.full_phone_number, pin: otp_verification_params[:pin])
      otp_check = code.verify_otp

      render json: otp_check
  end

  private

  def otp_verification_params
    params.require(:data).permit( :pin)
  end
end