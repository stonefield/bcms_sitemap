xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
xml.sitemapindex :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @entries.sort { |a,b| a[0] <=> b[0] }.each do |model,date|
    xml.sitemap do
      # xml.loc "http://#{SITE_DOMAIN}/sitemaps/#{path}.xml"
      xml.loc "#{sitemap_for_model_url(model)}"
      xml.lastmod date.xmlschema
    end
  end
end
