class BlogPost < ApiModel::Base
  attribute :name, String
  attribute :title, String

  class CustomBuilder
    def build(hash)
      BlogPost.new hash.merge(title: "FOOBAR")
    end
  end

  class AdvancedCustomBuilder
    def build(response, hash)
      response.metadata.custom_attr = "Hello"
      BlogPost.new hash
    end
  end

end
