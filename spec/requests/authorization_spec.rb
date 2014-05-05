require 'spec_helper'

describe "Authorization" do

  before(:each) {
    @course_1 = FactoryGirl.create(:course)
    @course_2 = FactoryGirl.create(:course)

    @teacher = FactoryGirl.create(:user)
    @student = FactoryGirl.create(:user)
    @student_without_courses = FactoryGirl.create(:user)

    @course_1.teachers << @teacher
    @course_1.students << @student

    @assignment = FactoryGirl.create(:assignment)
    @course_1.assignments << @assignment
  }


  shared_examples "allows access to public pages" do
    it "allows access to home page" do
      get root_path
      expect(response.status).to eq 200
    end
  end

  shared_examples "allows access to listings" do
    it "allows access to courses listing" do
      get courses_path
      expect(response.status).to eq 200
    end

    it "allows access to assignments listing" do
      get course_assignments_path(@course_1)
      expect(response.status).to eq 200
    end
  end

  shared_examples "denies access to listings" do
    it "denies access to courses listing" do
      get courses_path
      expect(response.status).not_to eq 200
    end

    it "denies access to assignments listing" do
      get course_assignments_path(@course_1)
      expect(response.status).not_to eq 200
    end
  end

  shared_examples "allows student level access" do
    it "allows submission of responses" do
      get new_course_assignment_response_path(@course_1, @assignment)
      expect(response.status).to eq 200
    end
  end

  shared_examples "denies student level access" do
    it "denies submission of responses" do
      get new_course_assignment_response_path(@course_1, @assignment)
      expect(response.status).not_to eq 200
    end
  end

  shared_examples "allows teacher level access" do
    it "allows editing of courses" do
      get edit_course_path(@course_1)
      expect(response.status).to eq 200
    end

    it "allows creation of assignments" do
      get new_course_assignment_path(@course_1)
      expect(response.status).to eq 200
    end

    it "allows editing of assignments" do
      get edit_course_assignment_path(@course_1, @assignment)
      expect(response.status).to eq 200
    end
  end

  shared_examples "denies teacher level access" do
    it "denies editing of courses" do
      get edit_course_path(@course_1)
      expect(response.status).not_to eq 200
    end

    it "denies creation of assignments" do
      get new_course_assignment_path(@course_1)
      expect(response.status).not_to eq 200
    end

    it "denies editing of assignments" do
      get edit_course_assignment_path(@course_1, @assignment)
      expect(response.status).not_to eq 200
    end
  end


  context "with a guest" do
    before(:each) {
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    }

    it_should_behave_like "allows access to public pages"
    it_should_behave_like "denies access to listings"
    it_should_behave_like "denies student level access"
    it_should_behave_like "denies teacher level access"
  end


  context "with a student without any courses" do
    before(:each) {
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@student_without_courses)
    }

    it_should_behave_like "allows access to public pages"
    it_should_behave_like "allows access to listings"
    it_should_behave_like "denies student level access"
    it_should_behave_like "denies teacher level access"
  end


  context "with a student enrolled in a course" do
    before(:each) {
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@student)
    }

    it_should_behave_like "allows access to public pages"
    it_should_behave_like "allows access to listings"
    it_should_behave_like "allows student level access"
    it_should_behave_like "denies teacher level access"
  end


  context "with a teacher" do
    before(:each) {
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@teacher)
    }

    it_should_behave_like "allows access to public pages"
    it_should_behave_like "allows access to listings"
    it_should_behave_like "allows student level access"
    it_should_behave_like "allows teacher level access"
  end


  context "with an admin" do
    before(:each) {
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(FactoryGirl.build(:user, admin: true))
    }

    it_should_behave_like "allows access to public pages"
    it_should_behave_like "allows access to listings"
    it_should_behave_like "allows student level access"
    it_should_behave_like "allows teacher level access"
  end
  
end
