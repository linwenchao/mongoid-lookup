
module Mongoid #:nodoc
  module Lookup #:nodoc
    
    module Collection
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        # configure the lookup collection
        def build_lookup_collection
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