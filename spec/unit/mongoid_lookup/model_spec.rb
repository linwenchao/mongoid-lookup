
require 'spec_helper'

describe Mongoid::Lookup::Model do
  
  describe '.build_lookup' do
    
    before :each do
      @model = Class.new
      @model.send(:include, Mongoid::Document)
      @model.send(:include, Mongoid::Lookup::Model)
    end
    
    context 'valid' do
      it 'defines a lookup reference' do
        @model.build_lookup :search, :collection => SearchListing
        lambda { @model::SearchReference }.should_not raise_error
      end
    
      it 'relates Model to Reference' do
        @model.build_lookup :search, :collection => SearchListing
        @model.new.should respond_to(:search_reference)
      end
    
      it 'attaches a save callback' do
        @doc = Person.new
        @doc.search_reference.should be_nil
        @doc.save
        @doc.search_reference.should_not be_nil
      end

      context 'collection given' do
        it 'extends the collection' do
          @model.build_lookup :search, :collection => SearchListing
          @model::SearchReference.superclass.should eq(SearchListing)
        end
      end

      context 'inherit is true' do
        before do
          @model.build_lookup :search, :collection => SearchListing
          @model_2 = Class.new(@model)
          @model_2.build_lookup :search, :inherit => true
        end

        it 'extends the nearest parent lookup' do
          @model_2::SearchReference.superclass.should eq(@model::SearchReference)
        end
      end
    end

    context 'invalid' do
      context 'collection and inherit are not given' do
        it 'raises a KeyError' do
          lambda do
            @model.build_lookup :search, {}
          end.should raise_error(KeyError)
        end
      end
      
      context 'inherit is given without valid parent' do
        it 'raises InheritError' do
          lambda do
            @model.build_lookup :search, :inherit => true
          end.should raise_error(Mongoid::Lookup::InheritError)
        end
      end
    end
  end
  
  describe 'lookup reference model' do
    it 'includes Reference' do
      Person::SearchReference.included_modules.should include(Mongoid::Lookup::Reference)
    end
  end
  
  describe '.lookup_reference' do
    it 'returns the reference model for the given ref name' do
      Person.lookup_reference(:search).should eq(Person::SearchReference)
    end
  end
  
  describe 'reference relation' do
    it 'relates to correct lookup reference model' do
      Person.new.build_search_reference.class.should eq(Person::SearchReference)
    end
  end
  
end