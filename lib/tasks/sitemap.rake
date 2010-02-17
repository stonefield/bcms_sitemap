namespace :sitemap do  
  desc 'Submit sitemap to relevant sites'
  task :submit => :environment do
    Cms::SitemapSubmitter.run
  end
  
  desc 'Check status of sitemap submission'
  task :status => :environment do
    fmt = "%-20.20s    %1.1s    %3u %s\n"
    printf fmt.gsub('u', 's'), 'Engine', 'Enabled', 'Sts', 'Last submit time'
    puts '-' * 60
    SearchEngine.all.each do |sitemap|
      printf fmt, sitemap.name, (sitemap.enabled? ? 'Y' : 'N'), sitemap.last_status, sitemap.submitted_at
    end
  end
  
  desc <<-DESC
    Verify that search engines verification files exists in pubic folder.
    If they are not there, they will be created.
    You want to run this as the last part of your deployment. If using capistrano you may add this to your deploy.rb file
    
    namespace :sitemap, :roles => :app do
      task :verify_signatories do
        rake = fetch(:rake, "rake")
        rails_env = fetch(:rails_env, "production")
        run "cd \#{current_path}; \#{rake} RAILS_ENV=\#{rails_env} sitemap:verify_signatories"
      end
    end
    after "deploy:finalize_update", "sitemap:verify_signatories"
  DESC
  task :verify_signatories => :environment do
    SearchEngine.verify_signatories!
  end
end
