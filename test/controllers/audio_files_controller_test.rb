require 'test_helper'

class AudioFilesControllerTest < ActionController::TestCase
  setup do
    @audio_file = audio_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audio_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create audio_file" do
    assert_difference('AudioFile.count') do
      post :create, audio_file: { convert_tries: @audio_file.convert_tries, ogg_name: @audio_file.ogg_name, path: @audio_file.path, wav_name: @audio_file.wav_name }
    end

    assert_redirected_to audio_file_path(assigns(:audio_file))
  end

  test "should show audio_file" do
    get :show, id: @audio_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @audio_file
    assert_response :success
  end

  test "should update audio_file" do
    patch :update, id: @audio_file, audio_file: { convert_tries: @audio_file.convert_tries, ogg_name: @audio_file.ogg_name, path: @audio_file.path, wav_name: @audio_file.wav_name }
    assert_redirected_to audio_file_path(assigns(:audio_file))
  end

  test "should destroy audio_file" do
    assert_difference('AudioFile.count', -1) do
      delete :destroy, id: @audio_file
    end

    assert_redirected_to audio_files_path
  end
end
