
require 'mongoid_searchable/collection'
require 'mongoid_searchable/model'

module Mongoid #:nodoc
  module Searchable #:nodoc
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      # Configures calling model as a search collection
      def searchable_collection
        include Collection
      end
      
      # Configures calling model as searchable
      def searchable options
        include Model
      end
      
    end
    
  end
end