# When using ApiModel in a Rails application, Rails will try to ascertain what type of class
# an instance of ApiModel::Base is when attempting to build a polymorphic route. Since ApiModel::Base
# inherits from Hashie, which in turn inherits from Hash, Rails thinks that an instance of
# ApiModel::Base is in fact a hash instead of acting like an ActiveModel, which then causes
# it to fail to compute a route for the class.
#
# This is a hacky workaround, but should not interfere with any core functionality since it just
# calls super if the class is not a subclass of ApiModel::Base.
Hash.class_eval do

  def self.===(klass)
    return false if klass.class.ancestors.include? ApiModel::Base
    super klass
  end

end