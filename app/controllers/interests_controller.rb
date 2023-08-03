class InterestsController < ApplicationController
    # before_action :set_interest, only: [:show, :edit, :update]
    # skip_before_action :verify_authenticity_token
    before_action :check_user

    def index
        user = auth_user
        if user.role == "admin"
            @interests = Interest.all
            if @interests.empty?
                render json: {
                    message: "No Interests Found",
                    interests: []
                }, status: 404
            else
                render json: {
                    message: "Found Interests",
                    interests: @interests
                }, status: 200
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    # def new
    #     @interest = Interest.new
    # end

    def create
        user = auth_user
        if user.role == "admin"
            @interest = Interest.new(interest_params)
            if @interest.save
                render json: {
                    message: "Interest created successfully"
                }, status: :ok
            else
                render json: {
                    message: "Unprosseable Entity"
                }, status: 422
            end
        else
            render json: {
                message: "Only admin can create the interest"
            }, status: 401
        end
    end

    # def show
    #     if @interest
    #         render json: {
    #             message: "Interest Found",
    #             interest: @interest
    #         }, status: 200
    #     else
    #         render json: {
    #             message: "Interest Not Found",
    #             interest: @interest
    #         }, status: 404
    #     end
    # end

    # def update
    #     if @interest.update(interest_params)
    #         render json: {
    #             message: "Interest Updated Successfully",
    #             interest: @interest
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
    #     if @interest.delete
    #         render json: {
    #             message: "Interest Deleted Successfully"
    #         }, status: 200
    #     else
    #         render ,json: {
    #             message: "Unauthorized"
    #         }, status: 401
    #     end
    # end

    private

    # def set_interest
    #     @interest = Interest.find(params[:id])
    # end

    def interest_params
        params.require(:interest).permit(:name)
    end
end
