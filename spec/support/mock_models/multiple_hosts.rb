class MultipleHostsFoo < ApiModel::Base
  api_config do |config|
    config.host = "http://foo.com"
  end
end

class MultipleHostsBar < ApiModel::Base
  api_config do |config|
    config.host = "http://bar.com"
  end
end

class MultipleHostsNone < ApiModel::Base
end