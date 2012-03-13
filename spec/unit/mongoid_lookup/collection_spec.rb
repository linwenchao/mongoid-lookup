
require 'spec_helper'

describe Mongoid::Lookup::Collection do
  
  describe '.build_lookup_collection' do
    
    it 'raises KeyError when :key option is not given' do
      @model = Class.new
      @model.send :include, Mongoid::Document
      @model.send :include, Mongoid::Lookup::Collection
      lambda { @model.build_lookup_collection({}) }.should raise_error(KeyError)
    end
    
    it 'adds a referenced relation' do
      SearchListing.new.should respond_to(:referenced)
    end
    
    it 'configures the lookup_key' do
      SearchListing.lookup_key.should eq(:label)
    end
    
  end
  
  describe '#lookup_field' do
    before do
      @ref = SearchListing.new
      @ref.label = 'x'
    end
    
    it 'reads from the lookup key field' do
      @ref.lookup_field.should eq('x')
    end
  end
  
  describe '#lookup_field=' do
    before do
      @ref = SearchListing.new
    end
    
    it 'writes to the lookup key field' do
      @ref.lookup_field = 'y'
      @ref.label.should eq('y')
    end
  end
  
end