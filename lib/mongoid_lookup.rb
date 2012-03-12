
require 'mongoid_lookup/collection'
require 'mongoid_lookup/model'
require 'mongoid_lookup/reference'

module Mongoid #:nodoc
  module Lookup #:nodoc
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      # Configures calling model as a lookup collection
      def lookup_collection
        include Collection unless included_modules.include?(Collection)
      end
      
      # Configures calling model as lookup
      def lookup name, options
        include Model unless included_modules.include?(Model)
        build_lookup(name, options)
      end
      
    end
    
  end
end