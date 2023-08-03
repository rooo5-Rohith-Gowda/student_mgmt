class AcademicsController < ApplicationController    
    before_action :set_academics, only: [:update, :destroy]
    before_action :check_user
    
    def index
        user = auth_user
        if user.role == 'admin'
            @academics = Academic.all
            if @academics.empty?
                render json: {
                    message: "No Academics Found",
                    academics: []
                }, status: 404
            else
                render json: {
                    message: "Found Academics",
                    academics: @academics
                }, status: 200
            end
        else
            render json: {
                message: 'your are not authorized to perform this action'
            }, status: 401
        end
    end

    def create
        user = auth_user
        if user.present? && user.role != 'admin'
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
                message: "You no need academics to log in"
            }, status: 401
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

    # def set_academics
    #     @academic = Academic.find(params[:id])
    # end

    def academic_params
        params.require(:academic).permit(:college_name, :interest_id, :qualification_id, :career_goals, :language, :other_language, :currently_working, :specialization, :experiance, :availability, :user_id, :governament_id, :cv)
    end
end
