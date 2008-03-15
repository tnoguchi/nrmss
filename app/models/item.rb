class Item < ActiveRecord::Base
  validates_presence_of :url, :name

  has_many :assigns
  has_many :groups, :through => :assigns
  # TODO: add images table
  #has_many :images


  # TODO: implement
  def image=(image); end

  def thumbnail_80; description; end

  # Update item info from public pages in Rakuten
  def update_info_from_rakuten
    result = Rakuten::Url.parse_html_to_hash(self.url)
    self.attributes = result
    self.save!
    self
  end
end
