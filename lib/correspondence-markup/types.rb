
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
  
  # An Item is text in a block with an associated ID.
  # Typically if would be a word in a sentence. Items are to 
  # be related to other items in other blocks in the same
  # translation that have the same ID.
  # When two or more items in the same block have the same ID, 
  # they are considered to be parts of the same item.
  # (For example, in "I let it go", we might want to identify "let" and "go" as a single item, 
  # because they are part of an English phrasal verb "let go", 
  # and its meaning is not quite the sum of the meanings of those two component words.)
  class Item
    
    include Helpers
    
    # The ID, which identifies the item (possibly not uniquely) within a given block.
    # An ID can be a comma-separated string of multiple IDs (this is relevant for partial
    # matching, and should only be used when there are more than two blocks in a translation
    # and one of the blocks has less granularity than other blocks in that translation).
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
  
  # A non-item is some text in a block that is not an item - it will
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
  
  # A Line is a sequence of items & non-items that will form part of a block.
  # Typically a line is one line of items (i.e. words) and non-items, or maybe
  # two or three lines which naturally group together within the
  # overall block (and which cannot be separated because they
  # translate to a single line in one of the other blocks in the
  # same translation).
  # Lines with the same ID in different blocks in the same
  # translation are related to each other, and may be shown next
  # to each other in the UI when the "Interleave" option is chosen.
  class Line
    
    # The ID which is unique in the block. It identifies the 
    # line uniquely within the block. It also serves as a default
    # prefix when parsing IDs for individual items.
    attr_reader :id
    
    # The array of items and non-items
    attr_reader :content
    
    # Initialize from ID and array of items and non-items
    def initialize(id, content)
      @id = id
      @content = content
    end

    # A line is equal to another line with the same IDs and the same content
    # (equality is only used for testing)
    def ==(otherLine)
      otherLine.class == Line && otherLine.id == @id && otherLine.content == @content
    end
    
    # Convert to HTML as a *<div>* tag with class *line*, *data-line-id* attribute
    # equal to the ID, and containing the HTML output for the content items and non-items
    # (with those converted according to the options for Helpers::text_to_html).
    def to_html(options={})
      "<div class=\"line\" data-line-id=\"#{@id}\">\n  " + 
        @content.map{|x| x.to_html(options)}.join("") + "\n</div>\n"
    end
  end
  
  # A block, containing a sequence of lines, as well as a type and a description.
  # A block will be one of two or more in a "translation".
  class Block
    
    # A short alphanumeric name for the type, typically reflecting the "language" of a block
    # where different blocks in a translation are different language versions of the same information.
    # It is used to determine a CSS class of the block. E.g. "english". (It can be nil.)
    attr_reader :type
    
    # A textual description of the type which will be displayed in the UI. E.g. "English".
    # Ideally it should be relatively concise. Can be nil.
    attr_reader :description
    
    # The array of lines that make up the content of the block.
    attr_reader :lines
    
    # Initialize from type, description and lines
    def initialize(type, description, lines)
      @type = type
      @description = description
      @lines = lines
    end

    # A block is equal to another block with the same type, description and lines
    # (equality is only used for testing)
    def ==(otherBlock)
      otherBlock.class == Block && otherBlock.type == @type  &&
        otherBlock.description == description &&
        otherBlock.lines == @lines
    end
    
    # From the type, determine the CSS class names to be used in the *<div>* element created
    # by to_html. If there is no type, then just "block", otherwise, "block <type>-block", 
    # e.g. if the type is "english",  then "block english-block".
    # (The "-block" suffix is used to reduce the chance of accidental CSS class name collisions.)
    def css_class_names
      class_names = "block"
      if @type != "" and @type != nil
        class_names = "block #{@type}-block"
      end
      class_names
    end
    
    # Convert to HTML as a *<div>* with CSS class determined by *css_class_names*.
    # Include a *<div>* of CSS class "language" (if the description is given)
    # Include HTML for the lines, converted according to the options for Helpers::text_to_html).
    def to_html(options={})
      lineHtmls = @lines.map{|x| x.to_html(options)}
      "<div class=\"#{css_class_names}\">\n  " + 
        (@description ? "<div class=\"language\">#{@description}</div>\n  " : "") +
        lineHtmls.join("").chomp("\n").gsub("\n", "\n  ") +
        "\n</div>\n"
    end
    
  end

  # A translation is a group of blocks. Different blocks in one translation
  # all represent the same content, but in different "languages". Items in different
  # blocks with the same item ID are shown in the UI as being translations of each other.
  # (Items with the same ID in the same block are also shown as related, and are presumed
  # to be different parts of a single virtual item.)
  class Translation
    
    # Optional description
    attr_reader :description
    
    # The array of blocks
    attr_reader :blocks
    
    # Initialize from the blocks
    def initialize(description, blocks)
      @description = description
      @blocks = blocks
    end

    # A translation is equal to another translation that has the same blocks
    # (equality is only used for testing)
    def ==(otherTranslation)
      otherTranslation.class == Translation && 
        otherTranslation.description == @description &&
        otherTranslation.blocks == @blocks
    end

    # Convert to HTML as a *<div>* of CSS class "translation" that contains the HTML
    # outputs from the blocks.
    # Options for Helpers::text_to_html can be provided as single true/false value, or, as arrays
    # of values, in which case the individual values are mapped to the corresponding blocks.
    def to_html(options={})
      numBlocks = blocks.length
      blockOptions = Array.new(numBlocks)
      for i in 0...numBlocks do
        blockOptions[i] = {}
      end
      for key in options.keys do
        value = options[key]
        if value.kind_of? Array
          for i in 0...([value.length, numBlocks].min) do
            blockOptions[i][key] = value[i]
          end
        else
          for i in 0...numBlocks do
            blockOptions[i][key] = value
          end
        end
      end
      blockHtmls = (0...(blocks.length)).map{|i| @blocks[i].to_html(blockOptions[i])}
      "<div class=\"translation\">\n  " + 
        (@description ? "<div class=\"description\">#{@description}</div>\n  " : "") +
        blockHtmls.join("").chomp("\n").gsub("\n", "\n  ") + 
        "\n</div>\n"
    end
  end
end
