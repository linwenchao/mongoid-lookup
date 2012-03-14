require 'place'

class City < Place
  
  lookup :search, :inherit => true, :map => { :code => :zipcode } do
    field :code, :type => String
  end
  
  field :zipcode, :type => String
  
end
