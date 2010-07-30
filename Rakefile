# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bcms_sitemap"
    gemspec.summary = "Sitemap submitter module for BrowserCMS"
    gemspec.description = "Sitemap submitter module for BrowserCMS, which enables submission of sitemap to different search engines"
    gemspec.email = "knut.stenmark@gmail.com"
    gemspec.homepage = "http://github.com/stonefield/bcms_sitemap"
    gemspec.authors = ["Knut Stenmark"]
    gemspec.files =  Dir["app/controllers/cms/search_engines_controller.rb"]
    gemspec.files += Dir["app/controllers/sitemaps_controller.rb"]
    gemspec.files += Dir["app/helpers/sitemaps_helper.rb"]
    gemspec.files += Dir["app/models/search_engine.rb"]
    gemspec.files += Dir["app/views/cms/search_engines/*"]
    gemspec.files += Dir["app/views/cms/shared/_admin_sidebar.html.erb"]
    gemspec.files += Dir["app/views/layouts"]
    gemspec.files += Dir["app/views/sitemaps"]
    gemspec.files += Dir["app/views/sitemaps/index.builder"]
    gemspec.files += Dir["app/views/sitemaps/model.builder"]
    gemspec.files += Dir["app/views/sitemaps/news_articles.builder"]
    gemspec.files += Dir["config/initializers/bcms_sitemap.rb"]
    gemspec.files += Dir["config/initializers/init_module.rb"]
    gemspec.files += Dir["db/migrate/*.rb"]
    gemspec.files -= Dir["db/migrate/*_browsercms_*.rb"]
    gemspec.files -= Dir["db/migrate/*_load_seed_data.rb"]
    gemspec.files -= Dir["db/migrate/*_news_articles.rb"]
    gemspec.files += Dir["lib/*"]
    gemspec.files += Dir["lib/bcms_sitemap/*"]
    gemspec.files += Dir["lib/tasks/*"]
    gemspec.files += Dir["rails/init.rb"]
    gemspec.add_dependency('browsercms', '>= 3.0.6')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
