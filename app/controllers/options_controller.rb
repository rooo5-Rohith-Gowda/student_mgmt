class OptionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        if current_user.role == "admin"
            @options = Option.all
            if @options.empty?
                render json: {
                    message: "No Options Found",
                    options: []
                }, status: 404
            else
                render json: {
                    message: "Found Options",
                    options: @options
                }, status: 200
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    def create
        if current_user.role == "admin"
            @option = Option.new(option_params)
            if @option.save
                render json: {
                    message: "Options created successfully"
                }, status: :ok
            else
                render json: {
                    message: "Unprosseable Entity"
                }, status: 422
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    def update
        if current_user.role == "admin"
            @option = Option.find(params[:id])
            if @option.update(option_params)
                render json: {
                    message: "Option Updated Successfully",
                    option: @option
                }, status: 200
            else
                render json: {
                    message: "Unproccessable entity",
                }, status: 422
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    private

    def option_params
        params.require(:option).permit(:choice, :assessment_question_id)
    end
end
