class Garage < ApiModel::Base
  attribute :car, Car
  attribute :style, String
end
