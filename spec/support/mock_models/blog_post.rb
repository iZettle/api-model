class BlogPost < ApiModel::Base
  attr_accessor :name, :title

  class CustomBuilder
    def build(hash)
      BlogPost.new hash.merge(title: "FOOBAR")
    end
  end

end