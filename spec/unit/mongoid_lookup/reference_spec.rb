
require 'spec_helper'

describe Mongoid::Lookup::Reference do
  
  it 'inherits referenced relation' do
    Person.lookup_reference(:search).new.should respond_to(:referenced)
  end
  
end