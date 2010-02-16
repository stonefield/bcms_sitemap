class SearchEngine < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :url, :if => :enabled?
  
  after_save :manage_signatory_file
  after_destroy :remove_signatory_file
  
  named_scope :enabled, :conditions => ['enabled = ?', true]
  
  def self.last_submit
    minimum(:submitted_at)
  end
    
  def submit
    if status = Cms::SitemapSubmitter.submit(self)
      self.update_attributes(:submitted_at => Time.now, :last_status => status)
    end
  end
  
  def signatory_folder
     File.join(Rails.root, 'public')
  end
  
  def signatory_file_name
    verification_file && File.join(signatory_folder, verification_file )
  end
  
protected
  def manage_signatory_file
    if verification_file_changed? || verification_content_changed?
      unless verification_file_was.nil?
        # new file_name - just remove the old one 
        File.delete File.join(signatory_folder, verification_file_was )
      end
      unless verification_file.empty?
        File.atomic_write(signatory_file_name) do |file|
          file.write(verification_content || '')
        end
      end
    end
  end

  def remove_signatory_file
    if signatory_file_name
      File.delete signatory_file_name
    end
  end
end
