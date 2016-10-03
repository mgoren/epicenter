desc "add location descriptor to all stripe payments"
task :update_stripe_payments => [:environment] do
  filename = File.join(Rails.root.join('tmp'), 'payments.txt')
  File.open(filename, 'w') do |file|          
    payments_updated = []
    Student.all.order(:created_at).each do |student|
      begin
        if student.payments.count == 0
          if student.plan
            file.puts("#{student.name}; 0; ?; ?; ?; NO PAYMENTS (PLAN: #{student.plan.name})")
          else
            file.puts("#{student.name}; 0; ?; ?; ?; NO PAYMENTS (NO PLAN)")
          end
        elsif student.courses.count == 0
          student.payments.each do |payment|
            payments_updated.push(payment)
            file.puts("#{student.name}; #{payment.amount / 100}; ?; ?; ?; NO COURSES LISTED")
          end
        else
          first_course = student.courses.order(:start_date).first
          location = first_course.office.name
          start_date = first_course.start_date.strftime("%Y-%m-%d")
          if first_course.description.include?("Evening") && student.payments.count == 1
            attendance_status = "Part-time"
          elsif first_course.description.include?("Evening")
            attendance_status = "Complicated (PT & FT)" # deal with this
          else
            attendance_status = "Full-time"
          end
          student.payments.each do |payment|
            payments_updated.push(payment)
            file.puts("#{student.name}; #{payment.amount / 100}; #{location}; #{start_date}; #{attendance_status}; ")
          end
        end
      rescue Exception => error
        file.puts("ERROR: #{student.name} - #{error.to_s}") # NOT EXPECTING THIS
      end
    end
    # now find orphan payments not connected to students (id 11 = Mike, id 112 = Courtney, 196 & 238 don't exist)
    Payment.all.each do |payment|
      if !payments_updated.include?(payment)
        file.puts("ORPHAN PAYMENT; #{payment.amount / 100}; ?; ?; ?; ORPHAN: payment_id #{payment.id} | student_id #{payment.student_id}")
      end
    end
  end
  puts "Exported to #{filename.to_s}"
end