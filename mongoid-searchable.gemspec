
Gem::Specification.new do |gem|

  gem.version     = File.read('VERSION').chomp
  gem.date        = File.mtime('VERSION').strftime('%Y-%m-%d')
  
  gem.name        = 'mongoid-searchable'
  gem.summary     = "Cross-model search indexing for the Mongoid ODM"
  gem.description = "Mongoid Searchable is an extension for the Mongoid ODM facilitating polymorphic search collectiongem."
  gem.authors     = ['Jeff Magee']
  gem.email       = 'jmagee.osrc@gmail.com'
  gem.homepage    = 'https://github.com/jmagee/mongoid-searchable'
  
  gem.files        = Dir.glob("lib/**/*") + %w(README.md)
  
  gem.add_dependency("mongoid", ["~> 2.4"])
  
  gem.add_development_dependency("rspec",       ["~> 2.6"])
  gem.add_development_dependency('redcarpet',   ['~> 2.1'])
  gem.add_development_dependency('yard',        ['>= 0.7.5'])

end