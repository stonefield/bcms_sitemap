require 'test_helper'
require 'test_factory'

class SitemapsHelperTest < ActionView::TestCase
  fixtures :page_routes
  
  context 'xml_url' do
    setup do
      page_routes(:new_article).reload_routes
      @news = create_news_article :name => 'good-news', :created_at => Date.parse('2010-03-03')
      flunk "Expected news article not to respond to path" if @news.respond_to?(:path)
      @page = create_page :path => '/home'
      flunk "Expected page to respond to path" unless @page.respond_to?(:path)
    end
    should 'handle objects which has path' do
      assert_equal "http://test.host/home", xml_url(@page)
    end
    should 'handle objects which does not have path' do
      assert_equal "http://test.host/news/articles/1/03/02/good-news", xml_url(@news)
    end
  end
end
