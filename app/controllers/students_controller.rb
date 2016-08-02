class StudentsController < ApplicationController
  authorize_resource
  before_filter :ensure_student_has_primary_payment_method, only: [:show]

  def index
    authorize! :manage, Course
    if params[:search]
      @query = params[:search]
      @results = Student.includes(:courses).search(@query).order(:name)
      render 'search_results'
    else
      redirect_to root_path
    end
  end

  def show
    @student = Student.find(params[:id])
    authorize! :manage, @student
    @course = Course.find(params[:course_id]) if params[:course_id]
    @interview_assignment = InterviewAssignment.new
    if current_student && @student.upfront_payment_due?
      @payment = Payment.new(amount: @student.upfront_amount_with_fees)
    elsif current_admin
      @payment = Payment.new
    end
  end

  def update
    if current_admin
      update_student_as_admin
    elsif current_student
      if current_student.update(student_params)
        redirect_appropriately
      else
        render_errors_appropriately
      end
    end
  end

private
  def student_params
    params.require(:student).permit(:primary_payment_method_id, :course_id, :interview_feedback,
                                    ratings_attributes: [:id, :internship_id, :notes, :number])
  end

  def update_student_as_admin
    @student = Student.find(params[:id])
    if @student.update(student_params)
      if params[:student][:interview_feedback]
        redirect_to course_student_path(Course.find(params[:course_id]), @student), notice: "Interview feedback added for #{@student.name}."
      else
        redirect_to student_courses_path(@student), notice: "Courses for #{@student.name} have been updated."
      end
    else
      @course = Course.find(params[:student][:course_id])
      render 'show'
    end
  end

  def redirect_appropriately
    if request.referer.include?('payment_methods')
      redirect_to payment_methods_path, notice: 'Primary payment method has been updated.'
    else
      @course = Course.find(Rails.application.routes.recognize_path(request.referrer)[:course_id])
      redirect_to course_student_path(@course, current_student), notice: 'Internship rankings have been updated.'
    end
  end

  def render_errors_appropriately
    if request.referer.include?('payment_methods')
      @payments = current_student.payments
      render 'payments/index'
    else
      @student = Student.find(params[:id])
      @course = Course.find(Rails.application.routes.recognize_path(request.referrer)[:course_id])
      render 'students/show'
    end
  end

  def ensure_student_has_primary_payment_method
    student = Student.find(params[:id])
    if current_student && !student.primary_payment_method && student == current_student
      redirect_to payment_methods_path
    end
  end
end
