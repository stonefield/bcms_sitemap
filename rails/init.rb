gem_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
Cms.add_to_rails_paths gem_root
Cms.add_generator_paths gem_root, "db/migrate/[0-9]*_*.rb"
Cms.add_generator_paths gem_root, "app/views/cms/shared/_admin_sidebar.html.erb"
Cms.add_generator_paths gem_root, "config/initializers/bcms_sitemap.rb"