xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.sitemapindex :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @entries.each_pair do |path,object|
    xml.sitemap do
      xml.loc "http://#{SITE_DOMAIN}/sitemaps/#{path}.xml"
      xml.lastmod xml_lastmod(object)
    end
  end
end
