Available as a gem at [RubyGems.org](http://rubygems.org)

# BCMS\_sitemap BrowserCMS sitemap submission module

This is a general purpose sitemap submission tool for BrowserCMS. It will automatically submit your site's sitemap to the search engines of
your preference. Once setup properly, it will submit the following url to your search engine: http://..yoursite../sitemaps.xml. This document
contains information about when your models were changed last time and urls for fetching your models sitemaps, e.g. the search engine will be
instructed to fetch http://..yoursite../sitemaps/pages.xml for your pages model.

Search engines wants sitemaps submitted no more often than once an hour. You will need to setup a cron or a backgroundrb job to submit your
sitemaps.

If you deploy remotely with capistrano you will want to change your deployment routines so that signatory (verification) files are 
re-created after deployment.

**Limitations:** Search engines do not accept more than 50,000 page references in a sitemap file. If you expect to have more than 50,000
active records in your models, then, you will need to implement paging in the module.


## Installation instructions

**Install the gem**

    sudo gem install bcms_sitemap

**Add it to your project**

Edit the config/environment.rb file and add the following after config.gem 'browsercms':

    config.gem 'bcms_sitemap'

**Install the new module**

From the root directory of your app, run the following:
  
    $ script/generate browser_cms
  
This will add the necessary files to you application. In particular, you may want to change the settings in
the file config/initializers/bcms\_sitemap.rb. (See also customization below)

Edit routes.rb file - add the following *before* map.routes\_for\_browser\_cms:

    map.routes_for_bcms_sitemap
  
**Run the migrations**

    $ rake db:migrate
  
**Register sitemap in robots.txt (optional)**  

Add the following line to your robots.txt

    Sitemap: http://...yoursite.../sitemaps.xml
  
**Additional setup**

In order for your sitemap to be submitted

* you will need to register your the search engine you would like to submit to
* You will need to setup a job that submits your sitemap.

See next section - configuration.


## Configuration

### Registering your search engines

To submit sitemap to search engines, you will need to enable the search engines in the search engines administrative pages. Some search
engines requires that you authenticate with the site. Where authentication is required, such as for Google, Yahoo, and Bing, you will have to
register some kind of verification, normally specified, using a verification file.

The search engine section in the admin pages will allow you to enter the required name and content for the verification files, 
and automatically create these upon saving the record for the individual search engines.

For more information see the individual sites:

[Google](http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=156184),
[Yahoo](http://help.yahoo.com/l/us/yahoo/smallbusiness/store/promote/sitemap/sitemap-16.html) and 
[yahoo submissions](https://siteexplorer.search.yahoo.com/submit), [Live/Bing](http://www.bing.com/webmaster)

[Ask](http://about.ask.com/en/docs/about/webmasters.shtml) and
[Moreover](http://moreover.com) does not require authentication. (Moreover is not really a search engine, but provides news many to companies)
  
[See also](http://www.hariesdesign.com/tips-and-trick/6-seo/46-submit-a-sitemap-to-top-5-search-engine) http://www.hariesdesign.com/tips-and-trick/6-seo/46-submit-a-sitemap-to-top-5-search-engine

Yahoo must be manually submitted the first time.
  
### Setting up your submission job
You can use either cron or backgroundrb to submit your sitemap. My preference is cron.
On a Ubuntu server you would do the following:

    sudo vi /etc/cron.hourly/submit_sitemaps

Add the following:

    #!/usr/bin/env ruby
    require 'fileutils'
    
    LUSER="...the user running the app..."
    APP_ROOT="/...yoursite..."
    RAILS_ENV="production"
    RAKE_OPTS='-q -s'
    Dir.chdir "#{APP_ROOT}/current"
    `su #{LUSER} -c "RAILS_ENV=#{RAILS_ENV} rake #{RAKE_OPTS} sitemap:submit"`    

Make it executable:

    sudo chmod 755 /etc/cron.hourly/submit_sitemaps

## Customizations (adding new models)

The sitemap submission facility has been setup with **pages** and **article\_news**. If you have more models that you want to add 
or remove, you need to change the bcms_sitemap.rb file in your config/initializers directory:

1. State what models to publish as a hash. 
2. The keys are plural name of the model.
3. The values should be the scope to be used, formed as string

    Cms::SitemapSubmitter.publish_models = {:pages => 'published.not_hidden' :news_articles => 'released'}

The bcms\_sitemap module will backport your model to access the scopes you define. 
It will also automatically respond to a defined route for your model, e.g. if you add 'feeds', it will publish the feeds sitemap at
http://...yoursite.../sitemaps/feeds.xml

By default the view is generated with the view app/views/sitemaps/models.builder (located with the gem). If you want differenciated
priorities or change modification frequencies, you can create your own builder. If so, you will have to give it a corresponding name, e.g. for 
feeds you would name the view feeds.builder. Below is the source code for the model.builder. 

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
    
The controller instanciates a variable with the model name pluralized, if you would prefere to use that, i.e. if the builder you are 
creating is for feeds, you may use @feeds instead of @objects.

## Rake tasks

There are three rake tasks:

* **sitemap:submit** which submits the sitemaps
* **sitemap:status** which lists the status of submitted sitemaps to the search engines
* **sitemap:verify_signatories** which re-creates signatory (verification) files after deployment, if necessary.

If you deploy using capistrano, you may want to add the sitemap:verify_signatories task deployment.rb

    namespace :sitemap, :roles => :app do
      task :verify_signatories do
        rake = fetch(:rake, "rake")
        rails_env = fetch(:rails_env, "production")
        run "cd \#{current_path}; \#{rake} RAILS_ENV=\#{rails_env} sitemap:verify_signatories"
      end
    end
    after "deploy:finalize_update", "sitemap:verify_signatories"


# Considerations for the future

Currently the module is placing a template for rendering the search engines in the administration interface, due to inflexible module
facilities in BrowserCMS. (Should be on the backlog for the browser cms team). Meanwhile, that view has to be stored locally.

# Issues

I have had some issues with submitting updates to yahoo. This is currently under investigation.