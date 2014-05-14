require 'spec_helper'

describe Enrollment do
  it "ensures (as best as it could) there are no duplicates" do
    @course = FactoryGirl.create(:course)
    @user = FactoryGirl.create(:user)

    expect{@course.students << @user}.to change{Enrollment.count}.from(0).to(1)
    expect{@course.students << @user}.to raise_error
    expect{@course.teachers << @user}.to change{Enrollment.count}.by(1)
  end
end
