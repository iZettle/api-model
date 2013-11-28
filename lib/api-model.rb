require 'active_model'

class ApiModel
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks

  define_model_callbacks :initialize

  def initialize(values={})
    run_callbacks :initialize do
      update_attributes values
    end
  end

  def update_attributes(values={})
    return unless values.present?

    values.each do |key,value|
      begin
        public_send "#{key}=", value
      rescue
        # TODO - log missing attr. Define attr perhaps?
      end
    end
  end

  def persisted?
    false
  end

end