class SitemapsController < ApplicationController
  caches_page :index, :pages, :news_articles
  
  def index
    @entries = {}
    %w(page news_article).each do |model|
      item = model.classify.constantize.published.first(:order => 'updated_at DESC')
      @entries[model.pluralize] = item if item 
    end
    respond_to do |format|
      format.xml
    end
  end
  
  def pages
    @pages = Page.published.not_hidden.all
  end
  
  def news_articles
    @articles = NewsArticle.released.all
  end

end
