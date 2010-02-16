require 'test_helper'

class SitemapsControllerTest < ActionController::TestCase  
  # Replace this with your real tests.
  
  should_route :get, '/sitemaps', :controller => :sitemaps, :action => :index
  should_route :get, '/sitemaps/pages', :controller => :sitemaps, :action => :pages
  should_route :get, '/sitemaps/news_articles', :controller => :sitemaps, :action => :news_articles
  
  XML_UTF8 = 'application/xml; charset=utf-8'
  
EXPECTED_SITEMAP = <<-TEXT
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>http://localhost:3000/sitemaps/pages.xml</loc>
    <lastmod>2010-02-05T10:54:49Z</lastmod>
  </sitemap>
  <sitemap>
    <loc>http://localhost:3000/sitemaps/news_articles.xml</loc>
    <lastmod>2010-02-05T10:54:49Z</lastmod>
  </sitemap>
</sitemapindex>
TEXT
EXPECTED_EMPTY_SITEMAP = <<-TEXT
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
</sitemapindex>
TEXT

def page(path, priority = 0.9, frequency = :daily, archived = false)
  @page = create_page(:path => path, :archived => archived)
  @expected = <<-TEXT
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://localhost:3000#{path}</loc>
    <lastmod>2010-02-05T10:54:49Z</lastmod>
    <changefreq>#{frequency}</changefreq>
    <priority>#{priority}</priority>
  </url>
</urlset>
TEXT
  end

  
  context 'sitemap' do
    setup do
      @request.env['Content-Type'] = 'application/xml'
      @time = Time.parse '2010-02-05T10:54:49Z'
      Time.stubs(:now).returns(@time)
    end
    context 'index' do
      setup do
        
        get :index, :format => 'xml'
      end
      should 'return successfully' do
        assert_response :success
      end
      should 'return correct format' do
        assert_equal XML_UTF8, @response.headers['Content-Type']
      end
      should 'return correct structure and no content' do
        assert_dom_equal EXPECTED_EMPTY_SITEMAP, @response.body
      end

      context 'having pages and news' do
        setup do
          @page = create_page 
          @news = create_news_article
          get :index, :format => 'xml'
        end
        should 'return correct structure and content' do
          assert_dom_equal EXPECTED_SITEMAP, @response.body
        end
      end
    end
    
    context 'pages' do
      setup do
        get :pages, :format => 'xml'
      end
      should 'generate map', :before => lambda { page('/')} do
        assert_dom_equal @expected, @response.body
      end
      should 'rank home page', :before => lambda { page('/', 0.9, :daily)} do
        assert_dom_equal @expected, @response.body
      end
      should 'rank navigation pages', :before => lambda { page('/nav/about', 0.4, :monthly)} do
        assert_dom_equal @expected, @response.body
      end
      should 'rank news pages', :before => lambda { page('/news/articles', 0.7, :daily)} do
        assert_dom_equal @expected, @response.body
      end
      should 'rank any non categorized pages', :before => lambda { page('/wow', 0.8, :weekly)} do
        assert_dom_equal @expected, @response.body
      end
      should 'rank any archived pages', :before => lambda { page('/wow', 0.3, :never, true)} do
        assert_dom_equal @expected, @response.body
      end
      should 'not include hidden pages', :before => lambda {
        @page = create_page(:path => '/im/hidden', :hidden => true)
      } do
          @expected = <<-TEXT
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
</urlset>
TEXT
        assert_dom_equal @expected, @response.body
      end
    end
    
    context 'articles' do
      setup do
        @article = create_news_article(:name => 'This is the name of the article', :release_date => @time.to_date)
      end
      should_eventually 'publish articles' do
        @expected = <<-TEXT
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url>
            <loc>http://localhost:3000/news/articles/2010/02/10/this-is-the-name-of-the-article</loc>
            <lastmod>2010-02-05T10:54:49Z</lastmod>
            <changefreq>weekly</changefreq>
            <priority>0.7</priority>
          </url>
        </urlset>
        TEXT
        get :news_articles, :format => 'xml'
        assert_response :success
        assert_dom_equal @expected, @response.body
      end
      should_eventually 'give archived articles lower priority' do
      end
    end
    
  end  
end
