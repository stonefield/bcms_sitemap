require 'cgi'
class Cms::SitemapSubmitter
  include ActionController::UrlWriter
  include ActionController::Caching::Pages
  
  class << self
    # Checks to see if there has been any updates since last time.
    # If so, clears the cache for the relevant model and submits the url to the search engine's that have not yet been notified
    def run
      submit_time = SearchEngine.enabled.minimum(:submitted_at)
      last_update_news = NewsArticle.released.maximum(:updated_at)
      last_update_pages = Page.published.not_hidden.maximum(:updated_at)
      last_update = [ last_update_news, last_update_pages].compact.max
      
      if last_update && (submit_time.nil? || submit_time < last_update)
        # This is a lazy cleaning of cache
        expire_page :controller => 'sitemaps', :action => 'index', :format => 'xml'
        expire_page :controller => 'sitemaps', :action => 'news_articles', :format => 'xml' if last_update_news && submit_time < last_update_news
        expire_page :controller => 'sitemaps', :action => 'pages', :format => 'xml' if last_update_pages && submit_time < last_update_pages
        SearchEngine.enabled.all.each do |search_engine|
          if search_engine.submitted_at.nil? || search_engine.submitted_at < last_update
            search_engine.submit
          end
        end
      end
    end

    # Submit a single search enging. Called from run through the search engine
    def submit(search_engine)
      sumbmitter = new(search_engine)
      sumbmitter.submit
    end
    
    def perform_caching
      ApplicationController.perform_caching
    end    
  end
  
  
  attr_accessor :search_engine, :connection
  def initialize(search_engine)
    @search_engine = search_engine
    @connection = ActiveResource::Connection.new(search_engine.url)
  end
  
  def submit
    response = 200
    begin
      @connection.get(document_url)
      logger.info "Sitemap was successfully submitted to #{search_engine.name} (#{document_url})"
    rescue => e
      logger.error "Sitemap submition failed for #{search_engine.name} (#{document_url})\nResponse was #{e.response}"
      response = e.response
    end
    response
  end
  
  def document_url
    @document_url ||= "#{search_engine.url}#{parameters}"
  end
  
  def parameters
    CGI.escape sitemaps_url(:host => SITE_DOMAIN, :format => :xml)
  end
  def logger
    RAILS_DEFAULT_LOGGER
  end
end
