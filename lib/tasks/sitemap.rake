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
  
end
