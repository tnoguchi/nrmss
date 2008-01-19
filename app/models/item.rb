class Item < ActiveRecord::Base
  has_many :assigns
  has_many :groups, :through => :assigns
  # TODO: add images table
  #has_many :images

  # TODO: implement
  def image=(image); end
end
