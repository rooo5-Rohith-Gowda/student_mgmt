class ApplicationController < ActionController::Base
    protect_from_forgery unless: -> { request.format.json? }

    private

    def check_user
        token = request.headers['token']&.split&.last
        payload= JWT.decode(token, nil, false).first
        if payload.present? && payload['exp'] >= Time.now.to_i
            user = User.find_by(id: payload['sub'])
            if user.present?
                @auth_user = user
            else
                render json: { message: 'User not found' }, status: :not_found
            end
        else
            render json: {
              message: "Invalid token or user not found"
            }, status: 404
        end
    rescue JWT::DecodeError => e
        render json: { message: 'Invalid token format' }, status: :unauthorized
    end

    def auth_user
        @auth_user || nil
    end
end
