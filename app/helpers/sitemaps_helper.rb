module SitemapsHelper
  def xml_lastmod(object)
    object.updated_at.xmlschema
  end
  
  def xml_url(object)
    "http://#{SITE_DOMAIN}#{object.path}"
  end
  
  def xml_article_url(object)
    news_article_url(object.route_params)
  end
end
