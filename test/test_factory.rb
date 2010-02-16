module TestFactory
  def _create(object)
    flunk object.errors.full_messages if object.new_record?
    object    
  end
  
  def new_search_engine(options = {})
    SearchEngine.new({:name => 'Google',
      :url => 'http://www.google.com/webmasters/tools/ping?sitemap=',
      :enabled => true}.merge(options))
  end
  def create_search_engine(options = {})
    _create SearchEngine.create({:name => 'Google',
      :url => 'http://www.google.com/webmasters/tools/ping?sitemap=',
      :enabled => true}.merge(options))
  end
  
  def create_page(options = {})
    _create Page.create({:name => 'Home', 
      :path => '/', 
      :template_file_name => 'home_page.html.erb',
      :hidden => false, 
      :published => true}.merge(options))
  end
  
  def create_news_article(options = {})
    _create NewsArticle.create({:name => 'Nyhet', :body => 'i dag', :published => true, :release_date => Date.today}.merge(options))
  end  
end