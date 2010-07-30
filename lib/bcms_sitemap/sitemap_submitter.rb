require 'cgi'
require 'net/https'
class Cms::SitemapSubmitter
  include ActionController::UrlWriter
  
  class << self
    
    # Checks to see if there has been any updates since last time.
    # If so, clears the cache for the relevant model and submits the url to the search engine's that have not yet been notified
    def run
      submit_time = SearchEngine.enabled.minimum(:submitted_at) || Time.now.years_ago(10)
      
      # collect timestamp for all models. We don't want to expire more pages than necessary
      timestamps = {}
      @models.each do |model|
        last_update = model.classify.constantize.bcms_sitemap_last_update
        timestamps[model] = last_update if last_update
      end
      last_update = timestamps.values.compact.max
      # try this {}.values.compact.max
      if last_update && (submit_time.nil? || (submit_time < last_update))
        # This is a lazy cleaning of cache
        expire_sitemap :controller => 'sitemaps', :action => 'index', :format => 'xml'

        @models.each do |model|
          expire_sitemap :controller => 'sitemaps', :action => model, :format => 'xml' if !timestamps[model] || submit_time < timestamps[model]
        end
        SearchEngine.enabled.all.each do |search_engine|
          if search_engine.submitted_at.nil? || search_engine.submitted_at < last_update
            search_engine.submit
          end
        end
      end
    end
    
    def expire_sitemap(options = {})
      return unless perform_caching
      ApplicationController::expire_page sitemap_path(options)
    end
    
    def sitemap_path(options = {})
      if options[:action] == 'index'
        "/#{options[:controller]}.#{options[:format]}"
      else
        "/#{options[:controller]}/#{options[:action]}.#{options[:format]}"
      end
    end

    # Submit a single search engine. Called from run through the search engine
    def submit(search_engine)
      sumbmitter = new(search_engine)
      sumbmitter.submit
    end

    # State what models to publish as a hash. 
    # The keys are the plural names of the models.
    # The values should be the scope to be used, formed as string
    #    Cms::SitemapSubmitter.publish_models = {:pages => 'published.not_hidden', :news_articles => 'released' }
    def publish_models=(models)
      models.each_pair do |model, scope|
        logger.debug "Backporting #{model} with bcms_sitemap accessors for selecting data - scope defined: '#{scope}'"
        src = <<-end_src
          class << self
            def bcms_sitemap_scope
              #{scope}.all
            end
            def bcms_sitemap_last_update
              #{scope}.maximum(:updated_at)
            end
          end
        end_src
        model.to_s.classify.constantize.class_eval src, __FILE__, __LINE__
      end
      @models = models.keys.collect { |k| k.to_s  }.sort
    end
    
    # the models defined by the application that will have sitemap information
    def models
      @models
    end
    
    def logger #:nodoc:
      RAILS_DEFAULT_LOGGER
    end
    
    def perform_caching #:nodoc:
      ApplicationController.perform_caching
    end    
  end
  
  
  attr_accessor :search_engine, :connection
  
  
  def initialize(search_engine) #:nodoc:
    @search_engine = search_engine
  end
  
  def submit #:nodoc:
    #puts "Submitting #{document_url}"
    resp = get document_url
    #puts "Response was #{resp.code} #{resp.message}"
    #puts "Body #{resp.body}"
    if resp.is_a? Net::HTTPOK
      logger.info "Sitemap was successfully submitted to #{search_engine.name} (#{document_url})"
    else
      logger.error "Sitemap submition failed for #{search_engine.name} (#{document_url})\nResponse was #{resp.code} #{resp.message}"
    end
    resp.code
  end
  
  def get(document_url)
    url = URI.parse(document_url)
    http = Net::HTTP.new(url.host, url.port)
    resp = http.send_request('GET', url.request_uri)
  end
  
  def document_url #:nodoc:
    @document_url ||= "#{search_engine.url}#{parameters}"
  end
  
  def parameters #:nodoc:
    CGI.escape "#{sitemaps_url(:host => SITE_DOMAIN)}"
  end
  
  def logger #:nodoc:
    self.class.logger
  end
end
