
require 'spec_helper'

describe Mongoid::Searchable::Model do
  
  describe '.configure' do
    
    before :all do
      @model = Class.new
      @model.send(:include, Mongoid::Document)
      @model.send(:include, Mongoid::Searchable)
    end
    
    it 'requires a collection' do
      #lambda { CleanModel.searchable({}) }.should raise_error(KeyError)
    end
    
  end
  
end