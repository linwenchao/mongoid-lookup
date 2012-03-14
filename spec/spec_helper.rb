
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app/models'))

require "mongoid"
require "mongoid_lookup"

Dir[ File.join(File.dirname(__FILE__), "app/models/*.rb") ].each do |file|
  require file
end

Mongoid.configure do |config|
  database = Mongo::Connection.new.db("mongoid_lookup_test")
  database.add_user("mongoid", "test")
  config.master = database
  config.logger = nil
end

RSpec.configure do |config|
  config.after(:each) do
    Mongoid.database.collections.each do |collection|
      unless collection.name =~ /^system\./
        collection.remove
      end
    end
  end
  
  config.after(:suite) do
    Mongoid.master.connection.drop_database("mongoid_lookup_test")
  end
end