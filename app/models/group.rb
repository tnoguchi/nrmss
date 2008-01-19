class Group < ActiveRecord::Base
  has_many :assigns
  has_many :items, :through => :assigns
end
