
require 'cgi'

module CorrespondenceMarkup
  
  module Helpers
    def text_to_html(text, options)
      html = text
      if options[:escaped]
        html = CGI.escape_html(html)
      end
      if options[:br]
        html = html.gsub("\n", "<br/>")
      end
      if options[:nbsp]
        html = html.gsub(" ", "&nbsp;")
      end
      html
    end
  end
  
  # An item is text in a structure with an associated id
  class Item
    include Helpers
    
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
      text_html = text_to_html(@text, options)
      "<span data-id=\"#{@id}\">#{text_html}</span>"
    end
  end
  
  # A non-item is text in a structure that is not an item - it is just text
  class NonItem
    include Helpers
    
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
      text_to_html(@text, options)
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
      numStructures = structures.length
      structureOptions = Array.new(numStructures)
      for i in 0...numStructures do
        structureOptions[i] = {}
      end
      for key in options.keys do
        value = options[key]
        if value.kind_of? Array
          for i in 0...([value.length, numStructures].min) do
            structureOptions[i][key] = value[i]
          end
        else
          for i in 0...numStructures do
            structureOptions[i][key] = value
          end
        end
      end
      structureHtmls = (0...(structures.length)).map{|i| @structures[i].to_html(structureOptions[i])}
      "<div class=\"structure-group\">\n  " + 
        structureHtmls.join("").chomp("\n").gsub("\n", "\n  ") + 
        "\n</div>\n"
    end
  end
end
