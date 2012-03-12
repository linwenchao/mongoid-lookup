
module Mongoid #:nodoc
  module Searchable #:nodoc
    
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