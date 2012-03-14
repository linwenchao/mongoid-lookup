require 'place'

class Country < Place
  
  has_lookup :search, :inherit => true
  
end
