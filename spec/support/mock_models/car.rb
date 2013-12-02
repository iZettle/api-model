class Car < ApiModel::Base

  property :number_of_doors, from: :numberOfDoors
  property :top_speed, transform_with: lambda { |speed| speed * 10 }

  def is_fast?
    top_speed > 300
  end

end