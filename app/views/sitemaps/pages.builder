xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @pages.each do |object|
    case object.path
    when /^\/nav\//
      freq = :monthly
      pri = 0.4
    when /^\/news\//
      freq = :daily
      pri = 0.7
    when /^\/$/
      freq = :daily
      pri = 0.9
    else
      freq = :weekly
      pri = 0.8
    end
    if object.archived?
      freq = :never
      pri = 0.3
    end
    xml.url do
      xml.loc xml_url(object)
      xml.lastmod xml_lastmod(object)
      xml.changefreq freq.to_s
      xml.priority pri
    end
  end
end
