
module Mongoid #:nodoc
  module Lookup #:nodoc
    
    module Model
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        # @param [Hash] options
        # @option options [Mongoid::Document] :collection
        def configure options
          options.fetch(:collection)
        end
        
      end
      
    end
    
  end
end