class ExportRatingsController < ApplicationController
  def create
    @course = Course.find(params[:course_id])
    respond_to do |format|
      format.csv { send_data Rating.limit(5).export_to_csv, filename: "#{@course.description}_rankings_#{Time.zone.now.to_date}.csv" }
    end
  end
end
