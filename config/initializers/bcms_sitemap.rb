# State what models to publish as a hash. 
# The keys are the plural names of the models.
# The values should be the scope to be used, formed as string
Cms::SitemapSubmitter.publish_models = {:pages => 'published.not_hidden', :news_articles => 'released'}