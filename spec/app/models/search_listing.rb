class SearchListing
  include Mongoid::Document
  include Mongoid::Lookup
  
  lookup_collection
  
  field :label, :type => String
  
end