module Cms::Routes
  def routes_for_bcms_sitemap
    sitemaps 'sitemaps', :controller => :sitemaps, :action => 'index'
    sitemap_for_model 'sitemaps/:model', :controller => :sitemaps, :action => 'model', 
      :requirements => { :model => /#{Cms::SitemapSubmitter.models.join('|')}/ }
    namespace :cms do |cms|
      cms.resources :search_engines
    end
  end
end