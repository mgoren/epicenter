class UpfrontPaymentsController < ApplicationController
  authorize_resource :payment

  def create
    @payment = current_student.make_upfront_payment
    if @payment.persisted?
      redirect_to student_path(current_student), notice: "Thank You! Your upfront payment has been made."
    else
      @student = current_student
      render 'payments/index'
    end
  end
end
