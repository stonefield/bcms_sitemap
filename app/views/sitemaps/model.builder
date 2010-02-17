xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @objects.each do |object|
    xml.url do
      xml.loc xml_url(object)
      xml.lastmod xml_lastmod(object)
      xml.changefreq 'weekly'
      xml.priority '0.5'
    end
  end
end
