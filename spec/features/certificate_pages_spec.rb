feature "print completion certificate" do
  context "before class is over" do
    it "doesn't show link to print certificate" do
      student = FactoryGirl.create(:student)
      login_as(student, scope: :student)
      visit edit_student_registration_path
      expect(page).to_not have_link "View your certificate of completion"
    end
  end

  context "after class ends" do
    it "allows student to print certificate" do
      course = FactoryGirl.create(:course)
      internship_course = FactoryGirl.create(:internship_course)
      student = FactoryGirl.create(:student, courses: [course, internship_course])
      travel_to internship_course.end_date + 1.day do
        login_as(student, scope: :student)
        visit edit_student_registration_path
        click_link "View certificate of completion"
        expect(page).to have_content "Epicodus Certificate of Completion"
        expect(page).to have_content student.name
      end
    end
  end
end
