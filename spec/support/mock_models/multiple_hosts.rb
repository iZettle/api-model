class MultipleHostsFoo < ApiModel::Base
  configure_api_model do |config|
    config.host = "http://foo.com"
  end
end

class MultipleHostsBar < ApiModel::Base
  configure_api_model do |config|
    config.host = "http://bar.com"
  end
end

class MultipleHostsNone < ApiModel::Base
end