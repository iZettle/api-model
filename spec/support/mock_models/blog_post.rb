class BlogPost < ApiModel::Base
  attribute :name, String
  attribute :title, String

  class CustomBuilder
    def build(hash)
      BlogPost.new hash.merge(title: "FOOBAR")
    end
  end

end
