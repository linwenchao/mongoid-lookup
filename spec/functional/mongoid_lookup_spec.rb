require 'spec_helper'

describe Mongoid::Lookup do
  
  before :each do
    @topic = Topic.create(:name => 'Politics')
    @city = City.create(:name => 'New York City', :population => 8125497, :zipcode => 10000)
    @country = Country.create(:name => 'USA', :population => 311591917)
  end
  
  describe SearchListing do
    it 'has one reference for each document' do
      SearchListing.count.should eq(3)
    end
  end
  
  describe Topic do
    
    it 'has a SearchListing' do
      @topic.search_reference.class.should eq(Topic::SearchReference)
    end
    
    describe Topic::SearchReference do
      it 'references a topic' do
        Topic::SearchReference.all.first.referenced.class.should eq(Topic)
      end
    end
    
  end
  
  describe Place::SearchReference do
    it 'has one reference for each place' do
      Place::SearchReference.count.should eq(2)
    end
  end
  
  describe City::SearchReference do
    
    it 'maintains tag fields' do
      @city.search_reference.label.should eq(@city.name)
    end
    
    it 'maintains place fields' do
      @city.search_reference.population.should eq(@city.population)
    end
    
    it 'maintains city fields' do
      @city.search_reference.code.should eq(@city.zipcode)
    end
    
  end
  
  describe Country::SearchReference do
    
    it 'maintains tag fields' do
      @country.search_reference.label.should eq(@country.name)
    end
    
    it 'maintains place fields' do
      @country.search_reference.population.should eq(@country.population)
    end
    
    it 'does not add fields' do
      @country.search_reference.should_not respond_to(:code)
    end
    
  end
  
end