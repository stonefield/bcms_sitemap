xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @news_articles.each do |object|
    xml.url do
      xml.loc news_article_url(object.route_params)
      xml.lastmod xml_lastmod(object)
      xml.changefreq object.archived? ? 'never' : 'weekly'
      xml.priority object.archived? ? 0.4 : 0.7
    end
  end
end
