class SearchListing
  include Mongoid::Document
  include Mongoid::Lookup
  
  lookup_collection :key => :label
  
  field :label, :type => String
  
end