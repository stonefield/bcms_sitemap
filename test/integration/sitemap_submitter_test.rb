require 'test_helper'

class Cms::SitemapSubmitterTest < ActiveSupport::TestCase
  
  context 'backporting models' do
    should 'be initialized' do
      assert Cms::SitemapSubmitter.models.is_a? Array
      assert Cms::SitemapSubmitter.models.include? 'pages'
      assert Cms::SitemapSubmitter.models.include? 'news_articles'
    end
    should 'just happen' do
      assert Page.respond_to? :bcms_sitemap_scope
      Cms::SitemapSubmitter.models.each do |model|
        assert model.classify.constantize.respond_to? :bcms_sitemap_scope
        assert model.classify.constantize.respond_to? :bcms_sitemap_last_update
      end
    end
  end
  
  context 'submitting sitemap' do
    setup do
      @search_engine = create_search_engine
      @submitter = Cms::SitemapSubmitter.new(@search_engine)
    end
    should 'return response code on success' do
      @submitter.stubs(:get).returns(Net::HTTPSuccess.new('1.1', 200, 'OK'))
      resp = @submitter.submit
      assert_equal 200, resp
    end
    should 'return response code on failure' do
      @submitter.stubs(:get).returns(Net::HTTPNotFound.new('1.1', 404, 'NotFound'))
      resp = @submitter.submit
      assert_equal 404, resp
    end
    should 'generate correct parameters' do
      assert_equal "http%3A%2F%2Ftest.host%2Fsitemaps.xml", @submitter.parameters
    end
  end
  
  context 'expiring cache for sitemap' do
    should 'execute' do
      ApplicationController.perform_caching = true
      assert_nil Cms::SitemapSubmitter.expire_sitemap( :controller => 'sitemaps', :action => 'test', :format => 'xml')
      ApplicationController.perform_caching = false
    end
  end
  
  context 'calculating path' do
    should 'exclude index from path' do
      assert_equal '/sitemaps.xml', Cms::SitemapSubmitter.sitemap_path(:controller => 'sitemaps', :action => 'index', :format => 'xml')
    end
    should 'include odel in path' do
      assert_equal '/sitemaps/test.xml', Cms::SitemapSubmitter.sitemap_path(:controller => 'sitemaps', :action => 'test', :format => 'xml')
    end
  end
  
  context 'run' do
    setup do
      @search_engine = create_search_engine
      Cms::SitemapSubmitter.stubs(:submit).returns(200)
    end
    
    should 'not submit if nothing updated' do
      Cms::SitemapSubmitter.run
      assert_nil @search_engine.reload.submitted_at
    end

    context 'based on updated' do
      setup do
        @search_engine.update_attributes(:submitted_at => Date.yesterday)
        @last_time = @search_engine.submitted_at
      end
      should 'submit if never submitted' do
        Cms::SitemapSubmitter.run
        assert_not_nil @search_engine.reload.submitted_at
      end
      context 'pages' do
        setup do
          @page = create_page
        end
        should 'submit if something is updated since last time' do
          Cms::SitemapSubmitter.run
          assert_not_equal @last_time, @search_engine.reload.submitted_at
        end
        should 'update last_status' do
          Cms::SitemapSubmitter.run
          assert_equal 200, @search_engine.reload.last_status
        end
      end
      context 'articles' do
        setup do
          @news = create_news_article
        end
        should 'submit if something is updated since last time' do
          Cms::SitemapSubmitter.run
          assert_not_equal @last_time, @search_engine.reload.submitted_at
        end        
      end
    end
  end
  
end
