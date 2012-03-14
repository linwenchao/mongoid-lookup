require "spec_helper"

describe Mongoid::Lookup do
  
  context "included" do
    
    it 'adds .lookup_collection' do
      Person.should respond_to(:lookup_collection)
    end
    
    it 'adds .has_lookup' do
      Person.should respond_to(:has_lookup)
    end

  end

  describe '.lookup_collection' do
    it 'includes Collection' do
      SearchListing.included_modules.should include(Mongoid::Lookup::Collection)
    end
  end
    
  describe '.lookup' do
    it 'includes Model' do
      Person.included_modules.should include(Mongoid::Lookup::Model)
    end
    
    it 'requires a configuration' do
      lambda { CleanModel.has_lookup }.should raise_error(ArgumentError)
    end
    
    it 'passes block to model' do
      @model = Class.new
      @model.send :include, Mongoid::Document
      @model.send :include, Mongoid::Lookup
      @model.has_lookup :search, :collection => SearchListing do
        field :xyz, type: String
      end
      @model.lookup(:search).fields.keys.should include('xyz')
    end
  end
    
end