
module CorrespondenceMarkup
  
  # An item is text in a structure with an associated id
  class Item
    attr_reader :id, :text
    
    def initialize(id, text)
      @id = id
      @text = text
    end
    
    def ==(otherItem)
      otherItem.class == Item && otherItem.id == @id && otherItem.text == @text
    end
  end
  
  # A non-item is text in a structure that is not an item - it is just text
  class NonItem
    attr_reader :text
    
    def initialize(text)
      @text = text
    end
    
    def ==(otherNonItem)
      otherNonItem.class == NonItem && otherNonItem.text == @text
    end
  end
end
