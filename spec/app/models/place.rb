require 'tag'

class Place < Tag
  
  lookup :search, :inherit => true, :map => { :population => :population } do
    field :population, :type => Integer
  end
  
  field :population, :type => Integer
  
end