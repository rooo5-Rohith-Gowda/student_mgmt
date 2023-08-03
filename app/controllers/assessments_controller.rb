class AssessmentsController < ApplicationController
    # skip_before_action :verify_authenticity_token
    before_action :check_user
    UNAUTHORIZED_MESSAGE = "You are not authorized to perform this action"

    def index
        user = auth_user
        if user.role == "admin"
            page = params[:page] || 1
            limit = params[:limit] || 50
            @assessments = Assessment.page(page).per(limit)
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
                message: UNAUTHORIZED_MESSAGE
            },status: 401
        end
    end


    def create
        user = auth_user
        if user.role == "teacher"
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
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    def update
        user =auth_user
        if user.role == "teacher"
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
                message: UNAUTHORIZED_MESSAGE
            }, status: 401
        end
    end

    # def show
    #     user = auth_user  
    #     if user.role == "teacher"
    #         assessment = Assessment.find_by(id: params[:id])
    #         if assessment
    #             questions = assessment.assessment_questions.includes(:options)
    #             if questions.any?
    #                 question_data = questions.map do |question|
    #                 {
    #                     question: question.question,
    #                     options: question.options.pluck(:text)
    #                 }
    #                 end
    #                 render json: {
    #                 assessment_id: assessment.id,
    #                 questions: question_data
    #                 }
    #             else
    #                 render json: {
    #                 message: "No Questions Found"
    #                 }, status: 404
    #             end
    #         else
    #             render json: {
    #                 message: "Assessment Not Found"
    #             }, status: 404
    #         end
    #     else
    #         render json: {
    #             message: UNAUTHORIZED_MESSAGE
    #         }, status: 401
    #     end
    # end

    def show_questions
        user = auth_user
        if user.role == "student"
            assessment = Assessment.find(params[:id])
            difficult = params[:difficult]
      
            questions = assessment.assessment_questions.includes(:options)
        
            if difficult
                questions = questions.where("level LIKE ?", "%#{difficult}%")
            end
        
            if questions.exists?
                random_question_ids = questions.pluck(:id).sample(4)
                random_questions = questions.where(id: random_question_ids)
                render json: random_questions.to_json(only: [:id, :question], include: { options: {only: [:choice]} })
            else
                render json: {
                    message: "No Questions Found for the Assessment",
                    questions: []
                },  status: :not_found
            end
        else
          render json: {
              message: UNAUTHORIZED_MESSAGE
          }, status: 401
        end
    end

    def submit_answer
        user = auth_user
        if user.role == "student"
          assessment = Assessment.find_by(id: params[:id])
          submitted_answers = params.fetch(:answers, {}).permit!.to_h
          
            if assessment.nil?
                render json: {
                message: "Assessment not found"
                }, status: :not_found
                return
            end
        
      
          if submitted_answers.empty? || !submitted_answers.is_a?(Hash)
            render json: {
              message: "Invalid Submission",
              errors: "Answers not provided or not in the correct format"
            }, status: :unprocessable_entity
            return
          end
      
          total_marks = 0
          question_results = []
      
          submitted_answers.each do |question_id_str, submitted_answer|
            question = assessment.assessment_questions.find_by(id: question_id_str.to_i)
      
            if question.nil?
                render json: {
                  message: "Question not found with ID: #{question_id_str}"
                }, status: :not_found
                return
            end
      
            correct_option = Option.find_by(id: question.correct_option)

            if correct_option.nil?
                render json: {
                  message: "Correct option not found for Question with ID: #{question_id_str}"
                }, status: :not_found
                return
            end
        
            correct_answer_text = correct_option.choice
      
            is_correct = (submitted_answer == correct_answer_text)
            question_results << {
              question_id: question.id,
              submitted_answer: submitted_answer,
              correct_answer: correct_answer_text,
              is_correct: is_correct
            }
      
            total_marks += 1 if is_correct
          end
          
          VerifyMailer.email(user, total_marks).deliver_now
          render json: {
            message: "Marks has been sent to your email",
            results: question_results,
            total_marks: total_marks
          }, status: :ok
        else
          render json: {
            message: UNAUTHORIZED_MESSAGE
          }, status: 401
        end
    end

    private

    def assessment_params
        params.require(:assessment).permit(:name)
    end
end
