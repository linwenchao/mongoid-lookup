
require 'spec_helper'

describe Mongoid::Lookup::Collection do
  
  describe '.build_lookup_collection' do
    
    it 'adds a referenced relation' do
      SearchListing.new.should respond_to(:referenced)
    end
    
  end
  
end