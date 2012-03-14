
require 'spec_helper'

describe Mongoid::Lookup::Reference do
  
  it 'inherits referenced relation' do
    Person.lookup_reference(:search).new.should respond_to(:referenced)
  end
  
  describe '.configure_lookup_reference' do
  
    before :each do
      @parent = Class.new
      @parent.send :include, Mongoid::Document
      @parent.send :include, Mongoid::Lookup::Reference
      @parent.configure_lookup_reference({ :map => { :x => :y, :a => :b } })
    end
  
    it 'defines a field_map instance variable' do
      @parent.lookup_field_map.should eq({ :x => :y, :a => :b })
    end
    
    context 'inherited reference' do
      before :each do
        @child = Class.new(@parent)
        @child.configure_lookup_reference({ :map => { :f => :g } })
      end
      
      it 'merges additional fields' do
        @child.lookup_field_map.should eq({ :x => :y, :a => :b, :f => :g })
      end
      
      it 'copies parent field map without changing parent' do
        @parent.lookup_field_map.should eq({ :x => :y, :a => :b })
      end
    end
    
  end
  
end