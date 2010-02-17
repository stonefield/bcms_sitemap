unless defined? GEM_BCMS_SITEMAP
  GEM_BCMS_SITEMAP = true
  Dir["#{Gem.searcher.find('bcms_sitemap').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }
end
