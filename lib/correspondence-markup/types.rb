
require 'cgi'

module CorrespondenceMarkup
  
  # An item is text in a structure with an associated id
  class Item
    attr_reader :id, :text
    
    def initialize(id, text)
      @id = id
      @text = text
    end
    
    def item?
      true
    end
    
    def ==(otherItem)
      otherItem.class == Item && otherItem.id == @id && otherItem.text == @text
    end
    
    def to_html(options={})
      text_html = CGI.escape_html(@text)
      if options[:br]
        text_html = text_html.gsub("\n", "<br/>")
      end
      if options[:nbsp]
        text_html = text_html.gsub(" ", "&nbsp;")
      end
      "<span data-id=\"#{@id}\">#{text_html}</span>"
    end
  end
  
  # A non-item is text in a structure that is not an item - it is just text
  class NonItem
    attr_reader :text
    
    def initialize(text)
      @text = text
    end
    
    def item?
      false
    end
    
    def ==(otherNonItem)
      otherNonItem.class == NonItem && otherNonItem.text == @text
    end
    
    def to_html(options={})
      html = CGI.escape_html(@text)
      if options[:br]
        html = html.gsub("\n", "<br/>")
      end
      if options[:nbsp]
        html = html.gsub(" ", "&nbsp;")
      end
      html
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
    
    def to_html(options={})
      "<div class=\"structure\">\n  " + @content.map{|x| x.to_html(options)}.join("") + "\n</div>\n"
    end
    
  end
  
  class StructureGroup
    attr_reader :structures
    
    def initialize(structures)
      @structures = structures
    end

    def ==(otherStructureGroup)
      otherStructureGroup.class == StructureGroup && otherStructureGroup.structures == @structures
    end

    def to_html(options={})
      "<div class=\"structure-group\">\n  " + 
        @structures.map{|x| x.to_html(options)}.join("").chomp("\n").gsub("\n", "\n  ") + 
        "\n</div>\n"
    end
  end
end
