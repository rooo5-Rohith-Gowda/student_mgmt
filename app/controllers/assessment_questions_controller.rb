class AssessmentQuestionsController < ApplicationController
    before_action :check_user
    UNAUTHORIZED_MESSAGE = "You are not authorized to perform this action"
    # skip_before_action :verify_authenticity_token

    def index
        user = auth_user
        if user.role == "admin"
            page = params[:page] || 1
            limit = params[:limit] || 50
            total_no_of_questions = AssessmentQuestion.count
            @assessment_questions = AssessmentQuestion.page(page).per(limit)
            if @assessment_questions.empty?
                render json: {
                    message: "No Questions Found",
                    assessment_questions: []
                }, status: 404
            else
                render json: {
                    page: page,
                    total_pages: (total_no_of_questions / limit.to_f).ceil,
                    total_no_of_questions: total_no_of_questions,
                    message: "Found Questions",
                    no_of_questions_per_page: @assessment_questions.count,
                    assessment_questions: @assessment_questions
                }, status: 200
            end
        else
            render json: {
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    def show
        user = auth_user
        if user.role =="admin"
            assessment_question = AssessmentQuestion.find_by(id: params[:id])
            if assessment_question
            render json: {
                question: assessment_question.question,
                options: assessment_question.options.pluck(:choice)
            }
            else
            render json: {
                message: "Question Not Found"
            }, status: 404
            end
        else
            render json:{
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end


    def create
        user = auth_user
        if user.role == "admin"
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
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    def update
        user = auth_user
        if user.role == "admin"
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
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    def destroy
        user = auth_user
        if user.role == "admin"
            @assessment_question = AssessmentQuestion.find(params[:id])
            @assessment_question.options.destroy_all
            if @assessment_question.delete
                render json: {
                    message: "Question Deleted Successfully"
                }, status: 200
            else
                render json: {
                    message: "Unproccessable entity"
                }, status: 422
            end
        else
            render json: {
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    private

    def assessment_question_params
        params.require(:assessment_question).permit(:question, :correct_option, :level, :assessment_id, options_attributes: [:id, :choice, :_destroy])
    end
end
