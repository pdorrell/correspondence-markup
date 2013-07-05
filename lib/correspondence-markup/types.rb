
require 'cgi'

module CorrespondenceMarkup
  
  module Helpers
    
    # Either 1: a tag enclosed in "<" & ">", possibly missing the ">", or, 2: text outside a tag
    TAGS_AND_TEXT_REGEX = /([<][^>]*[>]?)|([^<]+)/
    
    def self.split_tags_and_text(html)
      html.scan(TAGS_AND_TEXT_REGEX).to_a
    end
    
    def text_to_html(text, options)
      html = text
      if options[:escaped]
        html = CGI.escape_html(html)
      end
      if options[:br]
        html = html.gsub("\n", "<br/>")
      end
      if options[:nbsp]
        tags_and_text = Helpers.split_tags_and_text(html)
        html = tags_and_text.map do |tag_or_text| 
          if tag_or_text[0] then tag_or_text[0] else tag_or_text[1].gsub(" ", "&nbsp;") end
        end.join("")
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
  
  # A group of items & non-items that will form part of a structure
  class ItemGroup
    attr_reader :id, :content
    
    def initialize(id, content)
      @id = id
      @content = content
    end

    def ==(otherItemGroup)
      otherItemGroup.class == ItemGroup && otherItemGroup.id == @id && otherItemGroup.content == @content
    end
    
    def to_html(options={})
      "<div class=\"item-group\" data-group-id=\"#{@id}\">\n  " + 
        @content.map{|x| x.to_html(options)}.join("") + "\n</div>\n"
    end
  end
  
  # A structure, containing a sequence of items and non-items
  class Structure
    attr_reader :type, :item_groups
    
    def initialize(type, item_groups)
      @type = type
      @item_groups = item_groups
    end

    def ==(otherStructure)
      otherStructure.class == Structure && otherStructure.type == @type && otherStructure.item_groups == @item_groups
    end
    
    def css_class_names
      class_names = "structure"
      if @type != "" and @type != nil
        class_names = "structure #{@type}-structure"
      end
      class_names
    end
    
    def to_html(options={})
      itemGroupHtmls = @item_groups.map{|x| x.to_html(options)}
      "<div class=\"#{css_class_names}\">\n  " + 
        itemGroupHtmls.join("").chomp("\n").gsub("\n", "\n  ") +
        "\n</div>\n"
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
