
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
      
      it 'configures the lookup reference' do
        @model.build_lookup :search, :collection => SearchListing, :map => { :x => :y }
        @model.lookup(:search).lookup_field_map.should eq(:x => :y)
      end
    
      it 'relates Model to Reference' do
        @model.build_lookup :search, :collection => SearchListing
        @model.new.should respond_to(:search_reference)
      end
    
      it 'attaches a save callback' do
        @doc = Person.new
        @doc.search_reference.should be_nil
        @doc.name = 'x'
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
      
      context 'block given' do
        before do
          @model.build_lookup :search, :collection => SearchListing do
            field :xyz, :type => String
          end
        end
        
        it 'evaluates block in lookup class' do
          @model.lookup(:search).fields.keys.should include('xyz')
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
      Person.lookup(:search).should eq(Person::SearchReference)
    end
  end
  
  describe 'reference relation' do
    it 'relates to correct lookup reference model' do
      Person.new.build_search_reference.class.should eq(Person::SearchReference)
    end
    
    it 'is dependent => destroy' do
      person = Person.create(:name => "x")
      person.destroy
      Person::SearchReference.count.should eq(0)
    end
  end
  
  describe '#has_lookup_changes?' do
    before :each do
      @p = Person.new
      @p.name = 'x'
      @p.save
    end
    
    it 'returns false if there are no changes to the lookup map fields' do
      @p.should_not have_lookup_changes(:search)
    end
    
    it 'returns true if there are changes to the lookup map fields' do
      @p.name = 'y'
      @p.should have_lookup_changes(:search)
    end
  end
  
  describe '#lookup_reference_attributes' do
    before do 
      @p = Person.new
      @p.name = 'x'
    end
    
    it 'returns attributes for the given lookup' do
      @p.lookup_reference_attributes(:search).should eq({
        :label => 'x'
      })
    end
  end
  
  describe '#save' do
    before :each do
      @p = Person.new
      @p.name = 'x'
      @p.save
    end

    it 'creates a lookup reference' do
      @p.search_reference.label.should eq('x')
    end
    
    it 'updates lookup reference' do
      @p.name = 'y'
      @p.save
      @p.search_reference.reload.label.should eq('y')
    end
  end
  
end