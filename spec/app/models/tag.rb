require 'search_listing'

class Tag
  include Mongoid::Document
  include Mongoid::Lookup
  
  has_lookup :search, :collection => SearchListing, :map => { :label => :name }
  
  field :name, :type => String
  
end