require "spec_helper"

describe Mongoid::Lookup do
  
  context "included" do
    
    it 'adds .lookup_collection' do
      Person.should respond_to(:lookup_collection)
    end
    
    it 'adds .lookup' do
      Person.should respond_to(:lookup)
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
      lambda { CleanModel.lookup }.should raise_error(ArgumentError)
    end
  end
    
end