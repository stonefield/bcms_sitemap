require 'test_helper'
#require 'fileutils'
TEST_FILES_FOLDER = "#{RAILS_ROOT}/tmp/test"

class SearchEngineTest < ActiveSupport::TestCase  
  should_validate_presence_of :name
  should_validate_uniqueness_of :name, :case_sensitive => false
  
  context 'search_engine' do
    setup do
      @search_engine = create_search_engine
    end
    context 'validating' do
      should 'require url if enabled' do
        @search_engine.url = nil
        assert !@search_engine.valid?
      end
      should 'not require url if not enabled' do
        @search_engine.url = nil
        @search_engine.enabled = false
        assert @search_engine.valid?
      end
    end
    should 'have signatory_folder' do
      assert_equal "#{RAILS_ROOT}/public", @search_engine.signatory_folder
    end
  end
  
  context 'submition' do
    setup do
      @search_engine = create_search_engine
      Cms::SitemapSubmitter.stubs(:submit).returns(200)
      flunk if @search_engine.submitted_at || @search_engine.last_status
    end
    should 'update sumittion time stamp after submition' do
      @search_engine.submit
      assert_not_nil @search_engine.submitted_at
    end

    should 'update last_status' do
      @search_engine.submit
      assert_equal 200, @search_engine.reload.last_status
    end
  end
  
  def prepare_test_folder
    empty_test_folder
    Dir.mkdir TEST_FILES_FOLDER unless File.directory? TEST_FILES_FOLDER
  end
  
  def teardown_test_folder
    empty_test_folder
    Dir.delete TEST_FILES_FOLDER if File.directory? TEST_FILES_FOLDER
  end
  
  def empty_test_folder
    return unless File.directory? TEST_FILES_FOLDER
    Dir.glob("#{TEST_FILES_FOLDER}/*").each do |file_name|
      FileUtils.rm file_name
    end
  end
  
  context 'signatory files' do
    setup do
      prepare_test_folder
      @filename = "google1111111111111.html"
      @filecontent = 'google-site-verification: google1111111111111.html'
      @search_engine = new_search_engine(
        :verification_file => @filename,
        :verification_content => @filecontent)
      SearchEngine.stubs(:signatory_folder).returns(TEST_FILES_FOLDER)
      @search_engine.save
      @expected_file = "#{TEST_FILES_FOLDER}/#{@filename}"
    end
    teardown do
      teardown_test_folder
    end
    should 'know it it has a signatory file' do
      assert @search_engine.has_signatory_file?
    end
    should 'create file and fill content' do
      expected_file = "#{TEST_FILES_FOLDER}/#{@filename}"
      assert File.exist?(expected_file), "File was not created upon creation"
      file = File.new(expected_file)
      assert_equal @filecontent, file.read
      file.close
    end
    should 'remove file upon destruction' do
      assert File.exist?(@expected_file)
      @search_engine.destroy
      assert !File.exist?(@expected_file)
    end
    context 'being modified' do
      setup do
        @new_filename = "google222222222222.html"
        @new_content = 'google-site-verification: google222222222222.html'
      end
      should 'rename file if changed' do
        @search_engine.verification_file = @new_filename
        @search_engine.save
        assert !File.exist?("#{TEST_FILES_FOLDER}/#{@filename}")
        assert File.exist?("#{TEST_FILES_FOLDER}/#{@new_filename}")
      end
      should 'change content if changed' do
        @search_engine.verification_content = @new_content
        @search_engine.save
        file = File.new(@expected_file)
        assert_equal @new_content, file.read
        file.close
      end
    end
    context 'verification' do
      setup do
        flunk unless File.exist?(@expected_file)
        File.delete(@expected_file)
        flunk if File.exist?(@expected_file)
        SearchEngine.verify_signatories!
      end
      should 'create signatory files' do
        assert File.exist?(@expected_file)
      end
    end
    
  end
  
end
