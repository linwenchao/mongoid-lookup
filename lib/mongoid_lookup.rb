
require 'mongoid_lookup/collection'
require 'mongoid_lookup/model'
require 'mongoid_lookup/reference'

module Mongoid #:nodoc:
  module Lookup #:nodoc:
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      # Configures calling model as a lookup collection
      def lookup_collection
        include Collection
        build_lookup_collection
      end
      
      # Configures lookup on calling model.
      # accepts a block which will be evaluated
      # in the class of the generated lookup reference model
      def lookup name, options, &block;
        include Model unless included_modules.include?(Model)
        build_lookup(name, options, &block)
      end
      
    end
    
  end
end