module Cms::Routes
  def routes_for_bcms_sitemap
    resources :sitemaps, :only => :index, :collection => {:pages => :get, :news_articles => :get }
    namespace :cms do |cms|
      cms.resources :search_engines
    end
  end
end