class VerifyMailer < ApplicationMailer
    default from: "from@example.com"

    def email(user, total_marks)
        @user = user
        @total_marks = total_marks
        mail(to: @user.email, subject: 'Regarding your MCQ-Test result') do |format|
            format.text { render plain: "Hello, #{user.first_name}!\nYour MCQ test score: #{total_marks}"}
        end
    end
end
