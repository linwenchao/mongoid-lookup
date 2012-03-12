require 'search_listing'

class Person
  
  include Mongoid::Document
  include Mongoid::Searchable
  
  searchable :collection => SearchListing
  
end