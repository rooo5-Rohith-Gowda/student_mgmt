class AssessmentQuestionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        if current_user.role == "admin"
            @assessment_questions = AssessmentQuestion.all
            if @assessment_questions.empty?
                render json: {
                    message: "No Questions Found",
                    assessment_questions: []
                }, status: 404
            else
                render json: {
                    message: "Found Questions",
                    assessment_questions: @assessment_questions
                }, status: 200
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    def show
        if current_user.role =="admin"
            assessment_question = AssessmentQuestion.find_by(id: params[:id])
            if assessment_question
            render json: {
                question: assessment_question.question,
                options: assessment_question.options.pluck(:text)
            }
            else
            render json: {
                message: "Question Not Found"
            }, status: 404
            end
        else
            render json:{
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end


    def create
        if current_user.role == "admin"
            @assessment_question = AssessmentQuestion.new(assessment_question_params)
            if @assessment_question.save
                render json: {
                    message: "Question created successfully"
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
            @assessment_question = AssessmentQuestion.find(params[:id])
            if @assessment_question.update(assessment_question_params)
                render json: {
                    message: "Question Updated Successfully",
                    assessment_question: @assessment_question
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

    def destroy
        if current_user.role == "admin"
            @assessment_question = AssessmentQuestion.find(params[:id])
            if @assessment_question.delete
                render json: {
                    message: "Question Deleted Successfully"
                }, status: 200
            else
                render json: {
                    message: "Unauthorized"
                }, status: 401
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    private

    def assessment_question_params
        params.require(:assessment_question).permit(:question, :correct_option, :level, :assessment_id)
    end
end
