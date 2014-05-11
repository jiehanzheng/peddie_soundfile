require 'spec_helper'

module AuthenticationHelpers
  def sign_in_as(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(SessionsHelper).to receive(:current_user).and_return(user)
  end

  module ClassMethods
    def define_get_access_rule(allow_or_disallow, path_method, &block)
      instance_eval do
        it "should #{allow_or_disallow} access to #{path_method}" do
          if block_given?
            params = self.instance_eval(&block)
          else
            params = []
          end

          unless params.kind_of?(Array)
            params = [params]
          end

          get method(path_method).call(*params)

          if allow_or_disallow == :allow
            expect(response.status).to eq 200
          else
            expect(response.status).to eq 302
          end
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end


RSpec.configure do |c|
  c.include AuthenticationHelpers
  c.include Rails.application.routes.url_helpers
end


describe "Authorization" do

  before(:each) {
    AudioFile.skip_callback(:validation, :before, :save_file)

    @course_1 = FactoryGirl.create(:course)
    @course_2 = FactoryGirl.create(:course)

    @teacher = FactoryGirl.create(:user)
    @student = FactoryGirl.create(:user)
    @student_without_courses = FactoryGirl.create(:user)

    @course_1.teachers << @teacher
    @course_1.students << @student
    @course_2.teachers << @teacher
    @course_2.students << @student

    first_response = @course_1.assignments.first.responses.first
    first_response.user = @student
    first_response.save!
  }

  shared_examples "read access to public pages" do |allow_or_disallow|
    define_get_access_rule allow_or_disallow, :root_path
  end

  shared_examples "read access to his/her course, assignment, and response" do |allow_or_disallow|
    define_get_access_rule(allow_or_disallow, :course_path) { @course_1 }
    define_get_access_rule(allow_or_disallow, :course_assignment_path) { [@course_1, @course_1.assignments.first] }
    define_get_access_rule(allow_or_disallow, :course_assignment_response_path) { [@course_1, @course_1.assignments.first, @course_1.assignments.first.responses.first] }    
  end

  shared_examples "read access to other's responses" do |allow_or_disallow|
    define_get_access_rule(allow_or_disallow, :course_assignment_response_path) { [@course_2, @course_2.assignments.first, @course_2.assignments.first.responses.first] }    
  end

  context "with a guest" do
    before(:each) {
      sign_in_as nil
    }

    include_examples "read access to public pages", :allow
    include_examples "read access to his/her course, assignment, and response", :disallow
    include_examples "read access to other's responses", :disallow
  end

  context "with a student without any courses" do
    before(:each) {
      sign_in_as @student_without_courses
    }

    include_examples "read access to public pages", :allow
    include_examples "read access to his/her course, assignment, and response", :disallow
    include_examples "read access to other's responses", :disallow
  end

  context "with a student enrolled in a course" do
    before(:each) {
      sign_in_as @student
    }

    include_examples "read access to public pages", :allow
    include_examples "read access to his/her course, assignment, and response", :allow
    include_examples "read access to other's responses", :disallow
  end

  context "with a teacher" do
    before(:each) {
      sign_in_as @teacher
    }

    include_examples "read access to public pages", :allow
    include_examples "read access to his/her course, assignment, and response", :allow
    include_examples "read access to other's responses", :allow
  end

  context "with an admin" do
    before(:each) {
      sign_in_as FactoryGirl.build(:user, admin: true)
    }

    include_examples "read access to public pages", :allow
    include_examples "read access to his/her course, assignment, and response", :allow
    include_examples "read access to other's responses", :allow
  end
  
end
