
Mongoid::Lookup
===============

Mongoid::Lookup is an extension for the Mongoid ODM providing
support for cross-model document lookups. It has a broad range of applications
including versatile app-wide search. Mongoid::Lookup leverages
Mongoid's polymorphism support to provide intuitive filtering by model.

Simple Lookup
-------------

An ideal use for Mongoid::Lookup is cross-model search, i.e. the 
Facebook search box which returns Users, Groups, Pages, Topics, etc.

To begin, define a collection to use as a root for your lookup:

    require 'mongoid_lookup'
  
    class SearchListing
      include Mongoid::Document
      include Mongoid::Lookup
    
      lookup_collection
    
      field :label, type: String
    end
    
Next, for each model you'd like to reference in the `SearchListing` collection,
add a `has_lookup` relationship:

    class User
      include Mongoid::Document
      include Mongoid::Lookup
      
      has_lookup :search, collection: SearchListing, :map => { label: :full_name }
      
      field :full_name, type: String
    end
    
`has_lookup` does more than just add a relation to `SearchListing`. It actually creates
a new model extending `SearchListing`, which you can access by passing the name of the relation
to the `lookup` method:

    User.lookup(:search) #=> User::SearchReference
    User::SearchReference.superclass #=> SearchListing
    
Mongoid::Lookup will now maintain a reference document through the `User#search_reference` relation.
The `:map` option matches fields in `User::SearchReference` to fields in `User`.
`User::SearchReference#label` will be `User#full_name`. Whenever the user changes its name, 
its `#search_reference` will be updated:

    user = User.create(full_name: 'John Doe')
    user.search_reference #=> #<User::SearchReference label: "John Doe">
    user.update_attributes(full_name: "Jack Doe")
    user.search_reference.reload #=> #<User::SearchReference label: "Jack Doe">

The lookup collection won't be particularly useful, though, until you add more models:

    class Group
      include Mongoid::Document
      include Mongoid::Lookup
      has_lookup :search, collection: SearchListing, map: { label: :name }
      field :name, type: String
    end
    
    class Page
      include Mongoid::Document
      include Mongoid::Lookup
      has_lookup :search, collection: SearchListing, map: { label: :title }
      field :title, type: String
    end
    
References in the lookup collection relate back to the source document, `referenced`:

    User.create(full_name: 'John Doe')
    listing = SearchListing.all.first
    listing.referenced #=> #<User _id: 4f418f237742b50df7000001, _type: "User", name: "John Doe">
    
Now, you can add whatever functionality desired to your lookup collection. In our example,
we'd like to implement cross-model search:

    class SearchListing
      scope :label_like, ->(query) { where(label: Regexp.new(/#{query}/i)) }
    end
    
    SearchListing.label_like("J")
    #=> [ #<User::SearchReference label: "J User">, <Group::SearchReference label: "J Group">, <Page::SearchReference label: "J Page">  ]

Advanced Lookup
---------------

Building on the simple search example, suppose you have a structured tagging system:

    class Tag
      include Mongoid::Document
    end
    class Person < Tag; end
    class Topic < Tag; end
    class Place < Tag; end
    class City < Place; end
    class Region < Place; end
    class Country < Place; end
    
Sometimes you'll want results across all models (User, Group, Page, Tag)
but at other times you may only be interested in Tags, or even just Places. 
Mongoid makes type filtering easy, and Mongoid::Lookup leverages this feature.

Begin by defining a lookup on your parent class:

    class Tag
      include Mongoid::Lookup
      has_lookup :search, :collection => SearchListing, :map => { :label => :name }
      field :name, :type => String
    end

Mongoid::Lookup allows you to directly query just for tags:

    Tag.lookup(:search).label_like("B")
    #=> [ #<Topic::SearchReference label: "Business">, <Person::SearchReference label: "Barack Obama">, <City::SearchReference label: "Boston">  ] 

Alternatively, you can access the model by its constant, which has been named according to the
key `"#{name.to_s.classify}Reference"`:

    Tag::SearchReference.label_like(query)

`has_lookup :screen_name` would generate a reference model `Tag::ScreenNameReference`:

### Lookup Inheritance 

What if you're only interested in Places?

Your `Place` model can define its own lookup. 
Use the `:inherit => true` option in any child class
to create a finer grained lookup:

    class Place < Tag
      has_lookup :search, inherit: true
    end
    
The new lookup will inherit the configuration of Tag's `:search` lookup. Now you
can query Place references only, as needed:

    Place.lookup(:search).label_like("C")
    #=> [ #<Country::SearchReference label: "Canada">, <Region::SearchReference label: "California">, <City::SearchReference label: "Carson City">  ] 
    
or 

    Place::SearchReference.label_like("C")
    
This does not effect SearchListing or Tag::SearchReference. Mongoid knows
hows to limit the query.
      
### Extending Lookup Reference Models

If you would like your lookup references to maintain more data from your source model,
add the desired fields to the lookup collection:

    class SearchListing
      field :alias, type: String
    end
    
Now update your `:map` option in your lookup declarations:
    
    class User
      has_lookup :search, collection: SearchListing, :map => { label: :full_name, alias: :nickname }
      field :full_name, type: String
      field :nickname, type: String
    end

If you would like to include fields that only pertain to certain models, pass a block to
your `has_lookup` call. It will be evaluated in the context of the reference class. 
The following:

    class Place < Tag

      has_lookup :search, inherit: true, :map => { population: :population } do
        # this block is evaluated 
        # in Place::SearchReference
        field :population, type: Integer
      end
      
      field :population, type: Integer
    end
    
...adds a `#population` field to `Place::SearchReference` and maps it to `Place#population`.
This additional field and mapping will only exist to `Place` and its child classes.

Anytime that you define a lookup, the parent configurations (fields and mappings) will
be inherited, and the new ones added:

    class City < Place
    
      has_lookup :search, inherit: true, :map => { code: :zipcode } do
        # this block is evaluated 
        # in City::SearchReference
        field :code, type: Integer
      end
    
      field :zipcode, type: Integer
    end
    
`City::SearchReference` will maintain `#label`, `#population`, and `#code`, as per mappings
given in `Tag`, `Place`, and `City`.

The ability to subclass lookup references allows for some flexibility. For instance,
if you'd like search references to provide a `#summary` method:

    class SearchListing
      lookup_collection
    
      def summary
        referenced_type.name
      end
    end
    
    class Place < Tag
      has_lookup :search, inherit: true, :map => { population: :population } do
        field :population, type: Integer
        
        def summary
          super + " of population #{population}"
        end
      end
    end

    Topic.create(title: "Politics")
    City.create(name: 'New York City', population: 8125497)
    
    SearchListing.all.each do |listing|
      puts "#{listing.label} + (#{listing.summary})"
    end
    
    #=> "Politics (Topic)"
    #=> "New York City (City of population 8125497)"
    
Notes
-----

Presumably, write heavy fields aren't great candidates for lookup. Every time
the field changes, the lookup reference will have to be updated.

The update currently takes place in a `before_save` callback. If performance were a
concern, the hook could instead create a delayed job to update the lookup (not currently supported).

Authors
-------

* [Jeff Magee](http://github.com/jmagee) (jmagee.osrc at gmail dot com)


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