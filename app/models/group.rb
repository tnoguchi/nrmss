class Group < ActiveRecord::Base
  #acts_as_searchable :searchable_fields => [ :name, :description ] 

  has_many :assigns
  has_many :items, :through => :assigns
end
