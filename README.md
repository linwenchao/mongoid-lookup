
Mongoid::Lookup
===============

Mongoid::Lookup is an extension for the Mongoid ODM providing
support for cross-model document lookups. It has a broad range of applications
including versatile app-wide search. Mongoid::Lookup leverages
Mongoid's polymorphism support to provide intuitive filtering by model.

Simple Lookup
-------------

An ideal use for Mongoid::Lookup is cross-model search, as in the 
Facebook search box which returns Users, Groups, Pages, Topics, etc.

To begin, define a collection to use as a root for your lookup:

    require 'mongoid_lookup'
  
    class SearchListing
      include Mongoid::Document
      include Mongoid::Lookup
    
      lookup_collection
    
      field :label, type: String
    end
    
Next, for each model you'd like to reference in the SearchListing collection,
configure a lookup:

    class User
      include Mongoid::Document
      include Mongoid::Lookup
      
      # create a lookup named :search that 
      # saves to the SearchListing collection.
      lookup :search, collection: SearchListing, :map => { label: :full_name }
      
      field :full_name, type: String
    end
    
Mongoid::Lookup will now maintain a reference document in the search_listing collection.
Its label will be the full name of the user. Whenever the user changes its name, the 
search reference will be updated.

The lookup collection won't be particularly useful, though, until you add more models:

    class Group
      include Mongoid::Document
      include Mongoid::Lookup
      lookup :search, collection: SearchListing, map: { label: :name }
      field :name, type: String
    end
    
    class Page
      include Mongoid::Document
      include Mongoid::Lookup
      lookup :search, collection: SearchListing, map: { label: :title }
      field :title, type: String
    end
    
The SearchListing documents contain a reference to the source document:

    User.create(full_name: 'John Doe')
    SearchListing.all.first.label #=> 'Jeff'
    SearchListing.all.first.referenced #=> #<User _id: 4f418f237742b50df7000001, _type: "User", name: "John Doe">
    
To implement the search, add a scope to match the label:

    class SearchListing
      scope :label_like, ->(query) { where(label: Regexp.new(/#{query}/i)) }
    end
    
    query = "J"
    SearchListing.label_like(query)
    #=> [ #<User::SearchReference label: "J User">, <Group::SearchReference label: "J Group">, <Page::SearchReference label: "J Page">  ]

Advanced Lookup
---------------

Building on the simple example, suppose you have a structured tagging
system:

    class Tag
      include Mongoid::Document
    end
    class Person < Tag; end
    class Topic < Tag; end
    class Place < Tag; end
    class City < Place; end
    class Region < Place; end
    class Country < Place; end
    
Sometimes you want results across all models (User, Group, Page, Tag)
but at other times you only want Tags or Places. Mongoid makes type filtering
easy, and Mongoid::Lookup leverages this feature.

Begin by defining a lookup on your parent class:

    class Tag
      include Mongoid::Lookup
      lookup :search, :collection => SearchListing, :map => { :label => :name }
      field :name, :type => String
    end
    
As is, SearchListing documents will already reference all of Tag's child classes.
Additionally, Mongoid::Lookup allows you to directly query just for tags. Behind 
the scenes, Mongoid::Lookup has created a new model extending the lookup collection 
(SearchListing). You can access this model by passing the lookup key to the 
`lookup_reference` class method:

    query = 'B'
    Tag.lookup_reference(:search).label_like(query)
    #=> [ #<Topic::SearchReference label: "Business">, <Person::SearchReference label: "Barack Obama">, <City::SearchReference label: "Boston">  ] 

Alternatively, you can simply call the model itself, which has been named according to the
given key:

    Tag::SearchReference.label_like(query)

### Lookup Inheritance 

Anywhere in your class structure that you add a lookup, you'll have another 
way to narrow down your results. Use the `:inherit => true` option in child
class in a call to lookup with the same lookup key (:search):

    class Place < Tag
      lookup :search, inherit: true
    end
    
The new lookup will inherit the configuration of Tag's search lookup. Now you
can query Place references only, as needed:

    query = 'C'
    Place.lookup_reference(:search).label_like(query)
      
### Extending Lookup Reference Models

If you would like your lookup references to maintain more data from your source model,
simply add the fields to the lookup collection and to the `:map` option:

    class SearchListing
      field :alias, type: String
    end
    
    class User
      lookup :search, collection: SearchListing, :map => { label: :full_name, alias: :nickname }
      field :full_name, type: String
      field :nickname, type: String
    end

When you would like to include fields that only pertain to certain models, pass a block to
your lookup call. It will be evaluated in the context of the child class. The following:

    class Place < Tag
      lookup :search, inherit: true, :map => { population: :population } do
        field :population, type: Integer
      end
      
      field :population, type: Integer
    end
    
...adds a population field to Place::SearchListing and maps it to Place#population.
This additional field and mapping will only exist to Place and its child classes.
Anytime that you define a lookup, the parent configurations (fields and mappings) will
be inherited, and the new ones added:

    class City < Place
      lookup :search, inherit: true, :map => { code: :zipcode } do
        field :code, type: Integer
      end
    
      field :zipcode, type: Integer
    end
    
Here, City::SearchListing will maintain #label, #population, and #code.

The ability to subclass lookup results allows for some flexibility. 
For instance, if you would like to deal with all SearchListings in 
the same manner, but provide model specific details:

    class SearchListing
      def summary
        I18n.t("resource_labels.#{referenced_type}")
      end
    end
    
    class Place < Tag
      lookup :search, inherit: true, :map => { population: :population } do
        field :population, type: Integer
        
        def summary
          super + " of population #{population}"
        end
      end
    end

    SearchListing.all.each do |listing|
      puts "#{listing.label} + (#{listing.summary})"
    end
    

License
-------

Copyright (c) 2012 Jeff Magee

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.