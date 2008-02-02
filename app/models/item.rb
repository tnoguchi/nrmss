class Item < ActiveRecord::Base
  validates_presence_of :url, :name

  has_many :assigns
  has_many :groups, :through => :assigns
  # TODO: add images table
  #has_many :images


  # TODO: implement
  def image=(image); end

  def thumbnail_80; description; end
end
