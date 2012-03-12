require 'search_listing'

class Person
  
  include Mongoid::Document
  include Mongoid::Lookup
  
  lookup :search, :collection => SearchListing
  
end