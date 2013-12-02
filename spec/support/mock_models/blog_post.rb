class BlogPost < ApiModel::Base
  property :name
  property :title

  class CustomBuilder
    def build(hash)
      BlogPost.new hash.merge(title: "FOOBAR")
    end
  end

end