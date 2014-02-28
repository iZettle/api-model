Hashie::Dash.class_eval do

  # Prevent hashie from raising errors when trying to set properties which have not been defined.
  def assert_property_exists!(property)
    super rescue NoMethodError
  end

end