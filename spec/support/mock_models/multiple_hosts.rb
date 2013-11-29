class MultipleHostsFoo < ApiModel::Base
  self.api_host = "http://foo.com"
end

class MultipleHostsBar < ApiModel::Base
  self.api_host = "http://bar.com"
end

class MultipleHostsNone < ApiModel::Base
end