class SearchListing
  include Mongoid::Document
  include Mongoid::Searchable
  
  searchable_collection
  
end