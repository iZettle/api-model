class CarTopSpeed < Virtus::Attribute
  def coerce(value)
    value * 10 if value
  end
end

class Car < ApiModel::Base
  attribute :number_of_doors, Integer
  attribute :top_speed, CarTopSpeed
  attribute :name, String, default: "Ferrari"

  attribute_synonym :number_of_doors, :numberOfDoors, :nrOfDoors
  attribute_synonym :top_speed, :max_speed

  def is_fast?
    top_speed > 300
  end

end