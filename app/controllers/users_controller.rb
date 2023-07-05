class UsersController < ApplicationController
    def show
      @user = User.find(params[:id])
      @academic = @user.academic
  
        if @academic.present?
            render json: {
                status: 200,
                data: {
                    user: @user,
                    academic: @academic
                }
            }
        else
            render json: {
            user: @user,
            message: 'Academic details not found for this user.'
            }
        end
    end
end
  