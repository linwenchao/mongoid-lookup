
require 'spec_helper'

describe Mongoid::Lookup::Model do
  
  describe '.configure' do
    
    before :all do
      @model = Class.new
      @model.send(:include, Mongoid::Document)
      @model.send(:include, Mongoid::Lookup)
    end
    
    it 'requires a collection' do
      #lambda { CleanModel.lookup({}) }.should raise_error(KeyError)
    end
    
  end
  
end