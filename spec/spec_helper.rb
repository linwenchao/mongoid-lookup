
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app/models'))

require "mongoid"
require "mongoid_lookup"

Dir[ File.join(File.dirname(__FILE__), "app/models/*.rb") ].each do |file|
  require file
end