ActionController::Routing::Routes.draw do |map|
  map.routes_for_bcms_sitemap
  map.routes_for_bcms_news 
  map.routes_for_browser_cms
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
