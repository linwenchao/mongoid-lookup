
module Mongoid #:nodoc:
  module Lookup #:nodoc:
    
    module Reference
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        # @param [Array] options
        # @option options [Hash] :map
        def configure_lookup_reference options
          resolve_lookup_field_map(options)
        end
        
        # inherit field map and merge new fields
        #
        # @private
        def resolve_lookup_field_map options
          map = (superclass.instance_variable_get(:@field_map) or {}).dup.merge((options[:map] or {}))
          instance_variable_set(:@field_map, map)
        end
        
        # @return [Hash] map of source fields to reference fields
        def lookup_field_map
          instance_variable_get(:@field_map)
        end
        
      end
      
    end
    
  end
end