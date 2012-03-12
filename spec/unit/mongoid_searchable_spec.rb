require "spec_helper"

describe Mongoid::Searchable do
  
  context "included" do
    
    it 'adds .searchable_collection' do
      Person.should respond_to(:searchable_collection)
    end
    
    it 'adds .searchable' do
      Person.should respond_to(:searchable)
    end

  end

  describe '.searchable_collection' do
    it 'includes Collection' do
      SearchListing.included_modules.should include(Mongoid::Searchable::Collection)
    end
  end
    
  describe '.searchable' do
    it 'includes Model' do
      Person.included_modules.should include(Mongoid::Searchable::Model)
    end
    
    it 'requires a configuration' do
      lambda { CleanModel.searchable }.should raise_error(ArgumentError)
    end
  end
    
end