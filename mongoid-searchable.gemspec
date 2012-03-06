
Gem::Specification.new do |s|
  s.name        = 'mongoid-searchable'
  s.version     = '0.0.0'
  s.summary     = "Cross-model search indexing for the Mongoid ODM"
  s.description = "Cross-model search indexing for the Mongoid ODM"
  s.authors     = [ "Jeff Magee" ]
  s.email       = 'jmagee.osrc@gmail.com'
  s.files       = [ "lib/mongoid_searchable.rb" ]
  s.homepage    = 'https://github.com/jmagee/mongoid-searchable'
  
  s.add_dependency("mongoid", ["~> 2.4"])
  
  s.add_development_dependency("rspec", ["~> 2.6"])
end