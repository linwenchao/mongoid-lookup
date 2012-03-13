
module Mongoid #:nodoc
  module Lookup #:nodoc
    
    module Collection
      extend ActiveSupport::Concern
      
      included do
        cattr_accessor :lookup_key
      end
      
      # returns value of lookup key field
      def lookup_field
        read_attribute(self.class.lookup_key)
      end
      
      # writes to the lookup key vield
      # @param [Object] val
      def lookup_field= val
        write_attribute(self.class.lookup_key, val)
      end
      
      module ClassMethods
        
        # configure the lookup collection
        #
        # @param [Array] options
        # @option options [Symbol] :key field name to use as lookup key
        def build_lookup_collection options
          self.lookup_key = options.fetch(:key)
          relate_lookup_collection
        end
        
        # add polymorphic relation to referenced document
        #
        # @private
        def relate_lookup_collection
          belongs_to :referenced, :polymorphic => true
        end
        
      end
      
    end
    
  end
end