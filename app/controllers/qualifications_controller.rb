class QualificationsController < ApplicationController
    # skip_before_action :verify_authenticity_token
    # before_action :set_qualification, only: [:show, :edit, :update]
    before_action :check_user

    def index
        user = auth_user
        if user.role == "admin"
            @qualifications = Qualification.all
            if @qualifications.empty?
                render json: {
                    message: "No Qualification Found",
                    qualifications: []
                }, status: 404
            else
                render json: {
                    message: "Found Qualification",
                    qualifications: @qualifications
                }, status: 200
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    # def new
    #     @qualification = Qualification.new
    # end

    def create
        user = auth_user
        if user.role == "admin"
            @qualification = Qualification.new(qualification_params)
            if @qualification.save
                render json: {
                    message: "Qualification created successfully"
                }, status: :ok
            else
                render json: {
                    message: "Unprosseable Entity"
                }, status: 422
            end
        else
            render json: {
                message: "You are not autharized to perform this action"
            }, status: 401
        end
    end

    # def show
    #     if @qualification
    #         render json: {
    #             message: "Qualification Found",
    #             qualification: @qualification
    #         }, status: 200
    #     else
    #         render json: {
    #             message: "Qualification Not Found",
    #             qualification: @qualification
    #         }, status: 404
    #     end
    # end

    # def update
    #     if @qualification.update(qualification_params)
    #         render json: {
    #             message: "Qualification Updated Successfully",
    #             qualification: @qualification
    #         }, status: 200
    #     else
    #         render json: {
    #             message: "Unproccessable entity",
    #         }, status: 422
    #     end
    # end

    # def edit
    # end

    # def destroy
    #     if @qualification.delete
    #         render json: {
    #             message: "Qualification Deleted Successfully"
    #         }, status: 200
    #     else
    #         render ,json: {
    #             message: "Unauthorized"
    #         }, status: 401
    #     end
    # end

    private

    # def set_qualification
    #     @qualification = Qualification.find(params[:id])
    # end

    def qualification_params
        params.require(:qualification).permit(:name)
    end
end
