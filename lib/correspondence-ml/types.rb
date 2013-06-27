
module CorrespondenceMarkup
  class Item
    attr_reader :number, :text
    
    def initialize(number, text)
      @number = number
      @text = text
    end
    
    def ==(otherItem)
      otherItem.class == Item && otherItem.number == @number && otherItem.text == @text
    end
  end
end
