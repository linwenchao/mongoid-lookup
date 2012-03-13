
require 'spec_helper'

describe Mongoid::Lookup::Reference do
  
  it 'inherits referenced relation' do
    Person.lookup_reference(:search).new.should respond_to(:referenced)
  end
  
  it 'inherits lookup_key' do
    Person.lookup_reference(:search).lookup_key.should eq(:label)
  end
  
end