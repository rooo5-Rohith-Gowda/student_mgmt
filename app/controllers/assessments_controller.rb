class AssessmentsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
        if current_user.role == "admin"
            @assessments = Assessment.all
            if @assessments.empty?
                render json: {
                    message: "No Assessments Found",
                    assessments: []
                }, status: 404
            else
                render json: {
                    message: "Found Assessments",
                    assessments: @assessments
                }, status: 200
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            },status: 401
        end
    end


    def create
        if current_user.role == "teacher"
            @assessment = Assessment.new(assessment_params)
            if @assessment.save
                render json: {
                    message: "Assessment is created successfully"
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
        if current_user.role == "teacher"
            @assessment = Assessment.find_by(id: params[:id])
            if @assessment.update(assessment_params)
                render json: {
                    message: "Assessment Updated Successfully",
                    assessment: @assessment
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

    def show
        if current_user.role == "teacher"
            assessment = Assessment.find_by(id: params[:id])
            if assessment
                questions = assessment.assessment_questions.includes(:options)
                if questions.any?
                    question_data = questions.map do |question|
                    {
                        question: question.question,
                        options: question.options.pluck(:text)
                    }
                    end
                    render json: {
                    assessment_id: assessment.id,
                    questions: question_data
                    }
                else
                    render json: {
                    message: "No Questions Found"
                    }, status: 404
                end
            else
                render json: {
                    message: "Assessment Not Found"
                }, status: 404
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    def show_questions
        if current_user.role == "student"
            assessment = Assessment.find(params[:id])
            difficult = params[:difficult]
    
            questions = assessment.assessment_questions.includes(:options)
    
            if difficult.present?
                questions = questions.where("level LIKE ?", "%#{difficult}%")
            end

            if questions.any?
                render json: questions.to_json(only: [:id , :question ], include: { options: {only: [:choice]} })
            else
                render json: {
                    message: "No Questions Found for the Assessment",
                    questions: []
                },  status: :not_found
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    def submit_answer
        if current_user.role == "student"
            assessment = Assessment.find(params[:id])
            question = assessment.assessment_questions.find(params[:question_id])
            submitted_answer = params[:answer] 
        
            if question && submitted_answer
                is_correct = (submitted_answer == question.correct_option)
                render json: {
                    question_id: question.id,
                    submitted_answer: submitted_answer,
                    correct_answer: question.correct_option,
                    is_correct: is_correct
                }
            else
                render json: {
                    message: "Invalid Submission",
                    errors: "Question not found or answer not provided"
                }, status: :unprocessable_entity
            end
        else
            render json: {
                message: "You are not authorized to perform this action"
            }, status: 401
        end
    end

    private 

    def assessment_params
        params.require(:assessment).permit(:name)
    end
end
