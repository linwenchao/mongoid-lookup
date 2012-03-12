
require 'mongoid_lookup/collection'
require 'mongoid_lookup/model'

module Mongoid #:nodoc
  module Lookup #:nodoc
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      # Configures calling model as a search collection
      def lookup_collection
        include Collection
      end
      
      # Configures calling model as lookup
      def lookup options
        include Model
      end
      
    end
    
  end
end