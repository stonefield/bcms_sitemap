# BCMS\_sitemap BrowserCMS sitemap submission module

This is a general purpose sitemap submission tool for BrowserCMS.

**NOTE: Gem has not been built yet.**

## Installation instructions

**Install the gem**

    sudo gem install bcms_sitemap

**Add it to your project**

Edit the config/environment.rb file and add the following after config.gem 'browsercms':

    config.gem 'bcms_sitemap'

Edit routes.rb file - add the following *before* map.routes\_for\_browser\_cms:

    map.routes_for_bcms_sitemap
  
**Install the new module**

From the root directory of your app, run the following:
  
    $ script/generate browser_cms
  
This will add the necessary files to your project (See also customization below)

**Run the migrations**

    $ rake db:migrate
  
**Register sitemap in robots.txt (optional)**  

Add the following line to your robots.txt

    Sitemap: http://...mysite.../sitemaps.xml
  
**Additional setup**

In order for your sitemap to be submitted

* you will need to register your the search engine you would like to submit to
* You will need to setup a job that submits your sitemap.

See next section - configuration.


## Configuration

### Registering your search engines

To submit sitemap to search engines, you will need to enable the search engines in the search engines administrative pages.
Some search engines requires that you authenticate with the site. 
Where authentication is required, such as for Google, Yahoo, and Bing, you will have to register some kind of verification, 
normally specified, using a verification file.

For more information see the individual sites:

[Ask](http://about.ask.com/en/docs/about/webmasters.shtml),
[Google](http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=156184),
[Yahoo](http://help.yahoo.com/l/us/yahoo/smallbusiness/store/promote/sitemap/sitemap-16.html) and [yahoo submissions](https://siteexplorer.search.yahoo.com/submit),
[Live/Bing](http://www.bing.com/webmaster)

[Moreover](http://moreover.com) does not require authentication. (Not really a search engine, but provides news many to companies)
  
[See also](http://www.hariesdesign.com/tips-and-trick/6-seo/46-submit-a-sitemap-to-top-5-search-engine) http://www.hariesdesign.com/tips-and-trick/6-seo/46-submit-a-sitemap-to-top-5-search-engine
  
### Setting up your submission job
You can use either cron or backgroundrb to submit your sitemap. My preference is cron.
On a Ubuntu server you would do the following:

    sudo vi /etc/cron.hourly/submit_sitemaps

Add the following:

    #!/usr/bin/env ruby
    require 'fileutils'
    
    APP_ROOT="/...mysite..."
    RAILS_ENV="production"
    RAKE_OPTS='-q -s'
    Dir.chdir "#{APP_ROOT}/current"
    `RAILS_ENV=#{RAILS_ENV} rake #{RAKE_OPTS} sitemap:submit`

## Customizations (adding new models)

The sitemap submission facility has been setup with **pages** and **article\_news**. If you have more models that you want to add 
or remove your will need to either copy the following files to your local applicaion directory and modify them, or override them
as initializers:

* routes.rb
* app/controllers/sitemaps\_controller.rb
* lib/bcms\_sitemap/sitemap\_submitter.rb

In addition you will need to create a builder for the view.

The _page_ model is used as an example

**sitemaps_controller**

Add an action method, which makes the selection of data:

    def pages
      @pages = Page.published.not_hidden.all
    end
    
Add a view for it (app/views/sitemaps/pages.builder):

    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8" 
    xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
        xml.url do
          xml.loc xml_url(object)
          xml.lastmod xml_lastmod(object)
          xml.changefreq 'daily'
          xml.priority 0.5
        end
      end
    end
    
**sitemap\_submitter**

Modify the *run* method:

    def run
      submit_time = SearchEngine.enabled.minimum(:submitted_at)
      last_update_news = NewsArticle.released.maximum(:updated_at)
      last_update_pages = Page.published.not_hidden.maximum(:updated_at)
      # <<--- Add your method to see if anything has been modified 
      
      # Add last_update_model to the array below
      last_update = [ last_update_news, last_update_pages].compact.max
      
      if last_update && (submit_time.nil? || submit_time < last_update)
        # This is a lazy cleaning of cache
        expire_page :controller => 'sitemaps', :action => 'index', :format => 'xml'
        expire_page :controller => 'sitemaps', :action => 'news_articles', :format => 'xml' if last_update_news && submit_time < last_update_news
        expire_page :controller => 'sitemaps', :action => 'pages', :format => 'xml' if last_update_pages && submit_time < last_update_pages
        # <<--- Add your expiry page statement
        
        SearchEngine.enabled.all.each do |search_engine|
          if search_engine.submitted_at.nil? || search_engine.submitted_at < last_update
            search_engine.submit
          end
        end
      end
    end
    

## Rake tasks

There are two rake tasks:

* **sitemap:submit** which submits the sitemaps
* **sitemap:status** which lists the status of submitted sitemaps to the search engines


# Considerations for the future

I believe it is possible, with minor modifications, to generalize the facility. If 'sitemap' scopes, which filters out what can be submitted,
it will be easy to create a configuration which tells the system which models should be submitted to the search engines. 

Model example:

    class Page < ActiveRecord::Base
      named_scope :sitemap, :conditions => [...whatever...]
      ...
    end
    
    
Configuration example. File: config/initializers/bcms\_sitemap.rb

    Sitemap.publish_models = [:pages, :feeds, :news_articles]

