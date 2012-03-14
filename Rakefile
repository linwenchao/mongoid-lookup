require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec:unit") do |spec|
  spec.pattern = "spec/unit/**/*_spec.rb"
end

RSpec::Core::RakeTask.new("spec:functional") do |spec|
  spec.pattern = "spec/functional/**/*_spec.rb"
end

task :spec => [ "spec:unit", "spec:functional" ]
task :default => :spec