module Twilio
    class SmsService
       def initialize(to:, pin:)
        @to = to
        @pin = pin
       end

        def send_otp
            account_sid = ENV['TWILIO_ACCOUNT_SID']
            auth_token = ENV['TWILIO_AUTH_TOKEN']
            @client = Twilio::REST::Client.new(account_sid, auth_token)
            
            @client.verify
                    .v2
                    .services('VA2a089e899e07d5d3bd7e77af5e8175a9')
                    .verifications
                    .create(to: @to, channel: 'sms')
        end
        def verify_otp
            account_sid = ENV['TWILIO_ACCOUNT_SID']
            auth_token = ENV['TWILIO_AUTH_TOKEN']
            @client = Twilio::REST::Client.new(account_sid, auth_token)
            p @to
            verification_check = @client.verify
                            .v2
                            .services('VA2a089e899e07d5d3bd7e77af5e8175a9')
                            .verification_checks
                            .create(to: @to, code: @pin)
            return  {status: verification_check.status}
        end
    end
end