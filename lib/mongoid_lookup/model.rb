
module Mongoid #:nodoc
  module Lookup #:nodoc

    class InheritError < StandardError; end
    
    module Model
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        # Create a lookup of the given name on the host model.
        #
        # @param [Symbol] name name of lookup
        # @param [Hash] options
        # @option options [Mongoid::Document] :collection
        def build_lookup name, options
          define_lookup_reference(name, options)
          relate_lookup_reference(name, options)
        end
        
        # Create a class to serve as the model for the lookup
        # reference. Const is set within the current model.
        #
        # @private
        def define_lookup_reference name, options
          self.const_set("#{name.to_s.classify}Reference", Class.new(lookup_reference_parent(name, options)))
          self.lookup_reference(name).send(:include, Reference) unless included_modules.include?(Reference)
        end
        
        # lookup reference class for the given lookup name
        # 
        # @param [String, Symbol] name
        # @return [Mongoid::Lookup::Reference]
        def lookup_reference name
          self.const_get("#{name.to_s.classify}Reference")
        end
        
        # whether or not the given lookup is defined
        # 
        # @param [String, Symbol] name
        # @return [Boolean]
        def has_lookup? name
          self.const_defined?("#{name.to_s.classify}Reference")
        end
        
        # returns the appropriate lookup reference parent for 
        # the given options
        # 
        # @private
        # @param [String, Symbol] name
        # @param [Array] options
        # @return [Mongoid::Lookup::Collection, Mongoid::Lookup::Reference]
        # @raise KeyError if not inheriting and collection is not given
        def lookup_reference_parent name, options
          options[:inherit] ? nearest_lookup_reference(name) : options.fetch(:collection)
        end
        
        # returns the lookup reference for the given name
        # belonging to the nearest ancestor of the calling class.
        # 
        # @private
        # @param [String, Symbol] name
        # @return [Mongoid::Lookup::Reference]
        def nearest_lookup_reference name
          (self.ancestors - self.included_modules).each do |klass|
            if klass.respond_to?(:has_lookup?)
              if klass.has_lookup? name
                return klass.lookup_reference(name)
              end
            end
          end
          
          raise InheritError, "no ancestor of #{self.name} has a lookup named '#{name}'"
        end
        
        #
        #
        #
        def relate_lookup_reference name, options
        end
      end
      
    end
    
  end
end