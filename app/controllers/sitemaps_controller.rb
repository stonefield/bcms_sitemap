class SitemapsController < ApplicationController
  caches_page :index, :model
  
  def index
    @entries = {}
    Cms::SitemapSubmitter.models.each do |model|
      last_update = model.classify.constantize.bcms_sitemap_last_update
      @entries[model.pluralize] = last_update if last_update
    end
  end
  
  def model
    model = params[:model]
    @objects = model.classify.constantize.bcms_sitemap_scope
    instance_variable_set("@#{model}", @objects) # Template usually wants @pages, @news_articles etc
    if Rails.root.join('app','views','sitemaps',"#{model}.builder").exist?
      render "#{model}.builder"
    else
      render 'model.builder'
    end
  end  
end
