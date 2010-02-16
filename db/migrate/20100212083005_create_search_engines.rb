class CreateSearchEngines < ActiveRecord::Migration
  def self.up
    create_table :search_engines do |t|
      t.string :name
      t.boolean :enabled
      t.string :url
      t.string :verification_file
      t.text :verification_content
      t.integer :last_status
      t.timestamp :submitted_at
      t.timestamps
    end
    # Create a sample search engine
    SearchEngine.create :name => 'Google', :url => 'http://www.google.com/webmasters/tools/ping?sitemap='
    SearchEngine.create :name => 'Yahoo', :url => 'http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap='
    SearchEngine.create :name => 'Ask', :url => 'http://submissions.ask.com/ping?sitemap='
    SearchEngine.create :name => 'Live/Bing', :url => 'http://www.bing.com/webmaster/ping.aspx?siteMap='
    SearchEngine.create :name => 'Moreover', :url => 'http://api.moreover.com/ping?u='
  end

  def self.down
    drop_table :search_engines
  end
end
