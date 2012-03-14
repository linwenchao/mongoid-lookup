require 'place'

class City < Place
  
  has_lookup :search, :inherit => true, :map => { :code => :zipcode } do
    field :code, :type => String
  end
  
  field :zipcode, :type => String
  
end
