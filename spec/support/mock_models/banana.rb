class Banana < ApiModel::Base
  attr_accessor :color, :size, :ripe
  after_initialize :set_ripeness

  def set_ripeness
  	self.ripe = color == "yellow"
  end
end