
require 'cgi'

# Module containing the Ruby classes that define the nodes of the AST 
# created when parsing Correspondence-Markup language according to the
# grammar defined by *bracketed-grammar.treetop*.
# Each node class knows how to output itself as HTML as defined by the
# method *to_html*.
module CorrespondenceMarkup

  # Helper functions used when generating HTML
  module Helpers
    
    # Either 1: a tag enclosed in "<" & ">", possibly missing the ">", or, 2: text outside a tag
    TAGS_AND_TEXT_REGEX = /([<][^>]*[>]?)|([^<]+)/
    
    # Split some HTML source into tags and plain text not in tags.
    # (For example, so that the two can be processed differently, e.g. applying a transformation to text content
    # where you don't want the transformation to apply to the internals of directly-coded HTML tags.)
    def self.split_tags_and_text(html)
      html.scan(TAGS_AND_TEXT_REGEX).to_a
    end
    
    # Convert text content into HTML according to various true/false options.
    # Note: the text may contain HTML tags
    # * :escaped - if true, HTML-escape the text
    # * :br - if true, convert end-of-line characters to <br/> tags
    # * :nbsp - if true, convert all spaces in the text that is not in tags into &nbsp;
    # Of these options, *:escaped* only makes sense if you _don't_ want to include additional HTML
    # markup in the content; *:br* and *:nbsp* make sense for programming languages but not for 
    # natural languages.
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
  
  # An Item is text in a structure with an associated ID.
  # Typically if would be a word in a sentence. Items are to 
  # be related to other items in other structures in the same
  # structure group that have the same ID.
  # When two or more items in the same structure have the same ID, 
  # they are considered to be parts of the same item.
  # (For example, in "I let it go", we might want to identify "let" and "go" as a single item, 
  # because they are part of an English phrasal verb "let go", 
  # and its meaning is not quite the sum of the meanings of those two component words.)
  class Item
    
    include Helpers
    
    # The ID, which identifies the item (possibly not uniquely) within a given structure.
    # An ID can be a comma-separated string of multiple IDs (this is relevant for partial
    # matching, and should only be used when there are more than two structures in a group
    # and one of the structures has less granularity than other structures in that group).
    attr_reader :id
    
    # The text of the item.
    attr_reader :text

    # Initialize from ID and text.
    def initialize(id, text)
      @id = id
      @text = text
    end
    
    # Is this an item? (yes)
    def item?
      true
    end
    
    # An item is equal to another item with the same ID and text
    # (equality is only used for testing)
    def ==(otherItem)
      otherItem.class == Item && otherItem.id == @id && otherItem.text == @text
    end
    
    # Convert to HTML as a *<span>* element with *data-id* attribute set to the ID
    # according to options for Helpers::text_to_html
    def to_html(options={})
      text_html = text_to_html(@text, options)
      "<span data-id=\"#{@id}\">#{text_html}</span>"
    end
  end
  
  # A non-item is some text in a structure that is not an item - it will
  # not be related to any other text.
  class NonItem
    include Helpers
    
    # The text of the non-item
    attr_reader :text
    
    # Initialize from text
    def initialize(text)
      @text = text
    end
    
    # Is this an item? (no)
    def item?
      false
    end
    
    # A non-item is equal to another non-item with the same text
    # (equality is only used for testing)
    def ==(otherNonItem)
      otherNonItem.class == NonItem && otherNonItem.text == @text
    end
    
    # Convert to HTML according to options for Helpers::text_to_html
    def to_html(options={})
      text_to_html(@text, options)
    end
  end
  
  # A group of items & non-items that will form part of a structure.
  # Typically an item group is one line of items (i.e. words) and non-items, or maybe
  # two or three lines which naturally group together within the
  # overall structure (and which cannot be separated because they
  # translate to a single line in one of the other structures in the
  # same structure group).
  # Item groups with the same ID in different structures in the same
  # structure group are related to each other, and may be shown next
  # to each other in the UI when the "Interleave" option is chosen.
  class ItemGroup
    
    # The ID which is unique in the structure. It identifies the 
    # item group uniquely within the structure. It also serves as a default
    # prefix when parsing IDs for individual items.
    attr_reader :id
    
    # The array of items and non-items
    attr_reader :content
    
    # Initialize from ID and array of items and non-items
    def initialize(id, content)
      @id = id
      @content = content
    end

    # An item group is equal to another item group with the same IDs and the same content
    # (equality is only used for testing)
    def ==(otherItemGroup)
      otherItemGroup.class == ItemGroup && otherItemGroup.id == @id && otherItemGroup.content == @content
    end
    
    # Convert to HTML as a *<div>* tag with class *item-group*, *data-group-id* attribute
    # equal to the ID, and containing the HTML output for the content items and non-items
    # (with those converted according to the options for Helpers::text_to_html).
    def to_html(options={})
      "<div class=\"item-group\" data-group-id=\"#{@id}\">\n  " + 
        @content.map{|x| x.to_html(options)}.join("") + "\n</div>\n"
    end
  end
  
  # A structure, containing a sequence of item groups, as well as a type and a description.
  # A structure will be one of two or more in a "structure group".
  class Structure
    
    # A short alphanumeric name for the type, typically reflecting the "language" of a structure
    # where different structures in a group are different language versions of the same information.
    # It is used to determine a CSS class of the structure. E.g. "english". (It can be nil.)
    attr_reader :type
    
    # A textual description of the type which will be displayed in the UI. E.g. "English".
    # Ideally it should be relatively concise. Can be nil.
    attr_reader :description
    
    # The array of item groups that make up the content of the structure.
    attr_reader :item_groups
    
    # Initialize from type, description and item groups
    def initialize(type, description, item_groups)
      @type = type
      @description = description
      @item_groups = item_groups
    end

    # A structure is equal to another structure with the same type, description and item groups
    # (equality is only used for testing)
    def ==(otherStructure)
      otherStructure.class == Structure && otherStructure.type == @type  &&
        otherStructure.description == description &&
        otherStructure.item_groups == @item_groups
    end
    
    # From the type, determine the CSS class names to be used in the *<div>* element created
    # by to_html. If there is no type, then just "structure", otherwise, "structure <type>-structure", 
    # e.g. if the type is "english",  then "structure english-structure".
    # (The "-structure" suffix is used to reduce the chance of accidental CSS class name collisions.)
    def css_class_names
      class_names = "structure"
      if @type != "" and @type != nil
        class_names = "structure #{@type}-structure"
      end
      class_names
    end
    
    # Convert to HTML as a *<div>* with CSS class determined by *css_class_names*.
    # Include a *<div>* of CSS class "language" (if the description is given)
    # Include HTML for the item groups, converted according to the options for Helpers::text_to_html).
    def to_html(options={})
      itemGroupHtmls = @item_groups.map{|x| x.to_html(options)}
      "<div class=\"#{css_class_names}\">\n  " + 
        (@description ? "<div class=\"language\">#{@description}</div>\n  " : "") +
        itemGroupHtmls.join("").chomp("\n").gsub("\n", "\n  ") +
        "\n</div>\n"
    end
    
  end

  # A structure group is a group of structures. Different structures in one structure group
  # all represent the same information, but in different "languages". Items in different
  # structures with the same item ID are shown in the UI as being translations of each other.
  # (Items with the same ID in the same structure are also shown as related, and are presumed
  # to be different parts of a single virtual item.)
  class StructureGroup
    
    # The array of structures
    attr_reader :structures
    
    # Initialize from the structures
    def initialize(structures)
      @structures = structures
    end

    # A structure group is equal to another structure group that has the same structures
    # (equality is only used for testing)
    def ==(otherStructureGroup)
      otherStructureGroup.class == StructureGroup && otherStructureGroup.structures == @structures
    end

    # Convert to HTML as a *<div>* of CSS class "structure-group" that contains the HTML
    # outputs from the structures.
    # Options for Helpers::text_to_html can be provided as single true/false value, or, as arrays
    # of values, in which case the individual values are mapped to the corresponding structures.
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
