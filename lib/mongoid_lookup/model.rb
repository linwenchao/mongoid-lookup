
module Mongoid #:nodoc:
  module Lookup #:nodoc:

    class InheritError < StandardError; end
    
    module Model
      extend ActiveSupport::Concern
      
      # create or update the lookup reference if 
      # changes are present
      #
      # @param [Symbol] name name of lookup reference to update
      def maintain_lookup_reference name
        if has_lookup_changes?(name)
          attrs = lookup_reference_attributes(name)
          
          if ref = send("#{name}_reference")
            ref.update_attributes(attrs)
          else
            send("create_#{name}_reference", attrs)
          end
        end
      end
      
      # checks for dirty fields on the given lookup 
      #
      # @param [Symbol] name name of lookup to check
      # @return [Boolean]
      def has_lookup_changes? name
        lookup_fields = self.class.lookup_fields(name)
        changed_fields = changes.keys
        (changed_fields - lookup_fields).count < changed_fields.count
      end
      
      # the attributes required for the given lookup reference
      #
      # @param [Symbol] name name of lookup to check
      # @return [Hash]
      def lookup_reference_attributes name
        {}.tap do |attrs|
          map = self.class.lookup(name).lookup_field_map.invert
          map.keys.each do |source_field|
            attrs[map[source_field]] = read_attribute(source_field)
          end
        end
      end
      
      module ClassMethods
        
        # Create a lookup of the given name on the host model.
        #
        # @param [Symbol] name name of lookup
        # @param [Hash] options
        # @option options [Mongoid::Document] :collection
        def build_lookup name, options, &block;
          define_lookup_reference(name, options, &block)
          relate_lookup_reference(name, options)
          attach_lookup_reference_callback(name, options)
        end
        
        # Create a class to serve as the model for the lookup
        # reference. Const is set within the current model.
        #
        # @private
        def define_lookup_reference name, options, &block;
          const_set("#{name.to_s.classify}Reference", Class.new(lookup_reference_parent(name, options)))
          lookup(name).send(:include, Reference) unless included_modules.include?(Reference)
          lookup(name).configure_lookup_reference(options)
          if block_given?
            lookup(name).class_eval(&block)
          end
        end
        
        # lookup reference class for the given lookup name
        # 
        # @param [String, Symbol] name
        # @return [Mongoid::Lookup::Reference]
        def lookup name
          const_get("#{name.to_s.classify}Reference")
        end
        
        # the fields on the Model which map to fields on the
        # lookup reference 
        #
        # @param [Symbol] name
        # @return [Array<String>]
        def lookup_fields(name)
          lookup(name).lookup_field_map.values.collect{ |v| v.to_s }
        end
        
        # whether or not the given lookup is defined
        # 
        # @param [String, Symbol] name
        # @return [Boolean]
        def has_lookup? name
          const_defined?("#{name.to_s.classify}Reference")
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
          (ancestors - included_modules).each do |klass|
            if klass.respond_to?(:has_lookup?)
              if klass.has_lookup?(name)
                return klass.lookup(name)
              end
            end
          end
          
          raise InheritError, "no ancestor of #{self.name} has a lookup named '#{name}'"
        end
        
        # relate the Model to the created lookup Reference
        #
        # @private
        def relate_lookup_reference name, options
          has_one "#{name}_reference".to_sym, :as => :referenced, :class_name => lookup(name).name, :dependent => :destroy
        end
        
        # add a save hook for the given reference unless 
        # already defined (inheriting)
        #
        # @private
        def attach_lookup_reference_callback name, options
          return if options[:inherit]
          
          set_callback :save, :before do
            maintain_lookup_reference(name)
            true
          end
        end
        
      end
        
    end
    
  end
end