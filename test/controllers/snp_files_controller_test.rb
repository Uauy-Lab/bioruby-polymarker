require 'test_helper'

class SnpFilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get snp_files_show_url
    assert_response :success
  end

end
