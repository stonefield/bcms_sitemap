# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bcms_sitemap}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Knut Stenmark"]
  s.date = %q{2010-02-17}
  s.description = %q{Sitemap submitter module for BrowserCMS, which enables submission of sitemap to different search engines}
  s.email = %q{knut.stenmark@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.markdown"
  ]
  s.files = [
    "app/controllers/cms/search_engines_controller.rb",
     "app/controllers/sitemaps_controller.rb",
     "app/helpers/sitemaps_helper.rb",
     "app/models/search_engine.rb",
     "app/views/cms/search_engines/_form.html.erb",
     "app/views/cms/search_engines/edit.html.erb",
     "app/views/cms/search_engines/index.html.erb",
     "app/views/cms/search_engines/new.html.erb",
     "app/views/cms/shared/_admin_sidebar.html.erb",
     "app/views/sitemaps/index.builder",
     "app/views/sitemaps/model.builder",
     "app/views/sitemaps/news_articles.builder",
     "config/initializers/bcms_sitemap.rb",
     "config/initializers/init_module.rb",
     "db/migrate/20100212083005_create_search_engines.rb",
     "lib/bcms_sitemap.rb",
     "lib/bcms_sitemap/routes.rb",
     "lib/bcms_sitemap/sitemap_submitter.rb",
     "lib/tasks/sitemap.rake",
     "rails/init.rb"
  ]
  s.homepage = %q{http://github.com/stonefield/bcms_sitemap}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Sitemap submitter module for BrowserCMS}
  s.test_files = [
    "test/functional/sitemaps_controller_test.rb",
     "test/integration/sitemap_submitter_test.rb",
     "test/performance/browsing_test.rb",
     "test/test_factory.rb",
     "test/test_helper.rb",
     "test/unit/helpers/sitemaps_helper_test.rb",
     "test/unit/search_engine_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<browsercms>, [">= 3.0.6"])
    else
      s.add_dependency(%q<browsercms>, [">= 3.0.6"])
    end
  else
    s.add_dependency(%q<browsercms>, [">= 3.0.6"])
  end
end

