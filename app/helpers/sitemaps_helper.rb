module SitemapsHelper
  def xml_lastmod(object)
    object.updated_at.xmlschema
  end
  
  def xml_url(object)
    if object.respond_to? :path
      "http://#{SITE_DOMAIN}#{object.path}"
    elsif object.respond_to? :route_params
      polymorphic_url(object, object.route_params)
    else
      polymorphic_url(object)
    end
  end
  
  def xml_article_url(object)
    news_article_url(object.route_params)
  end
end
