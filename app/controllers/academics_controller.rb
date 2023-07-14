class AcademicsController < ApplicationController
    before_action :set_academics, only: [:update, :destroy]

    def index
        @academics = Academic.all
        if @academics.empty?
            render json: {
                message: "No Qualification Found",
                academics: []
            }, status: 404
        else
            render json: {
                message: "Found Qualification",
                academics: @academics
            }, status: 200
        end
    end

    def create
        token = request.headers['token']&.split&.last
        payload= JWT.decode(token, nil, false).first
        p payload

        if payload.present? && payload['exp'] >= Time.now.to_i
            user = User.find_by(id: payload['sub'])
            if user.present?
            @academic = Academic.new(academic_params)
            @academic.user_id = user.id
            if @academic.save
                render json: {
                message: "Academics Created Successfully",
                academic: @academic
                }, status: 200
            else
                render json: {
                message: "Unprocessable Entity"
                }, status: 422
            end
        else
          render json: {
            message: "Invalid token or user not found"
          }, status: 404
        end
      end
    end

    # def update
    #     if @academic.update(academic_params)
    #         render json: {
    #             message: "Academics Updated Successfully",
    #             academic: @academic
    #         }, status: 200
    #     else
    #         render json: {
    #             message: "Unproccessable entity"
    #         }, status: 422
    #     end
    # end

    # def destroy
    #     if @academic.delete
    #         render json: {
    #             message: "Academic details Deleted Successfully"
    #         }, status: 200
    #     else
    #         render json: {
    #             message: "Unauthorized"
    #         }, status: 401
    #     end
    # end

    private

    rescue_from JWT::DecodeError do
        render json: { message: 'Invalid token' }, status: :unprocessable_entity
    end

    # def set_academics
    #     @academic = Academic.find(params[:id])
    # end

    def academic_params
        params.require(:academic).permit(:college_name, :interest_id, :qualification_id, :career_goals, :language, :other_language, :currently_working, :specialization, :experiance, :availability, :user_id, :governament_id, :cv)
    end
end
