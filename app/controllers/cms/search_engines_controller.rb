class Cms::SearchEnginesController < Cms::ResourceController 
  layout 'cms/administration'
  check_permissions :administrate  
  before_filter :set_menu_section
  protected
    def show_url
      index_url
    end
    
    def order_by_column
      "name"
    end
    
  private
    def set_menu_section
      @menu_section = 'search_engines'
    end

end
