
Gem::Specification.new do |gem|

  gem.version     = File.read('VERSION').chomp
  gem.date        = File.mtime('VERSION').strftime('%Y-%m-%d')
  
  gem.name        = 'mongoid-lookup'
  gem.summary     = "Cross-model lookup support for Mongoid"
  gem.description = "Mongoid::Lookup is an extension for the Mongoid ODM providing support for cross-model document lookups."
  gem.authors     = ['Jeff Magee']
  gem.email       = 'jmagee.osrc@gmail.com'
  gem.homepage    = 'https://github.com/jmagee/mongoid-lookup'
  
  gem.files        = Dir.glob("lib/**/*") + %w(README.md)
  
  gem.add_dependency("mongoid", ["~> 2.4"])
  
  gem.add_development_dependency("rspec",       ["~> 2.6"])
  gem.add_development_dependency('redcarpet',   ['~> 2.1'])
  gem.add_development_dependency('yard',        ['>= 0.7.5'])

end