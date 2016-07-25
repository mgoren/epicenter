class Rating < ActiveRecord::Base
  belongs_to :student
  belongs_to :internship

  validates :internship_id, presence: true, uniqueness: { scope: :student_id }
  validates :number, presence: true

  def self.for(internship, current_student)
    if !current_student
      nil
    elsif current_student.ratings.where(internship_id: internship.id).any?
      current_student.find_rating(internship)
    else
      current_student.ratings.new
    end
  end

  def self.export_to_csv
    require 'csv'

    attributes = %w{student internship number}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |rating|
        csv << attributes.map{ |attr| rating.send(attr) }
      end
    end
  end
end
