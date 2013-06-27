
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
  
  # A structure, containing a sequence of items and non-items
  class Structure
    attr_reader :content
    
    def initialize(content)
      @content = content
    end

    def ==(otherStructure)
      otherStructure.class == Structure && otherStructure.content == @content
    end
  end
  
  class StructureGroup
    attr_reader :structures
    
    def initialize(structures)
      @structures = structures
    end
  end
end
