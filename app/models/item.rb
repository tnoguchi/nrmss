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
    if result == {}	# データ取得失敗 (削除されたなど)
      self.update_attributes!(:rms_type => 999) unless self.new_record?
    else	# データ取得成功
      self.update_attributes!(result.reject { |k,v| !self.class.column_names.include?(k.to_s) })
    end
    self
  end
end
