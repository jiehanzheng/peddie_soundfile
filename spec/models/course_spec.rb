require 'spec_helper'

describe Course do
  describe "#associate_students_on_email_list!" do
    let(:course) { FactoryGirl.build(:course, email_list: <<-EMAIL_LIST)
1@example.com
2@example.com
EMAIL_LIST
    }

    before {
      @student_1 = FactoryGirl.create(:user, email: '1@example.com')
      @student_2 = FactoryGirl.create(:user, email: '2@example.com')
      @student_3 = FactoryGirl.create(:user, email: '3@example.com')
    }

    it "adds students specified in the student email list" do
      course.associate_students_on_email_list!
      expect(course.students).to contain_exactly(@student_1, @student_2)
    end
  end
end
