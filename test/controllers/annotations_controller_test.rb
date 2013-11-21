require 'test_helper'

class AnnotationsControllerTest < ActionController::TestCase
  setup do
    @annotation = annotations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:annotations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create annotation" do
    assert_difference('Annotation.count') do
      post :create, annotation: { end_second: @annotation.end_second, notes: @annotation.notes, response_id: @annotation.response_id, sound_file_id: @annotation.sound_file_id, start_second: @annotation.start_second }
    end

    assert_redirected_to annotation_path(assigns(:annotation))
  end

  test "should show annotation" do
    get :show, id: @annotation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @annotation
    assert_response :success
  end

  test "should update annotation" do
    patch :update, id: @annotation, annotation: { end_second: @annotation.end_second, notes: @annotation.notes, response_id: @annotation.response_id, sound_file_id: @annotation.sound_file_id, start_second: @annotation.start_second }
    assert_redirected_to annotation_path(assigns(:annotation))
  end

  test "should destroy annotation" do
    assert_difference('Annotation.count', -1) do
      delete :destroy, id: @annotation
    end

    assert_redirected_to annotations_path
  end
end
