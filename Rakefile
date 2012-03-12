require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec:unit") do |spec|
  spec.pattern = "spec/unit/**/*_spec.rb"
end

task :spec => [ "spec:unit" ]
task :default => :spec