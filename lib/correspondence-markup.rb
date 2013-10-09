require 'polyglot'
require 'treetop'

require 'correspondence-markup/bracketed-grammar'

module CorrespondenceMarkup
  
  # Compiler that parses and compiles correspondence markup source code 
  # into an array of Translation objects (from which HTML can be
  # generated in the format required by correspondence.js).
  class CorrespondenceMarkupCompiler
    
    # Initialize by creating the CorrespondenceMarkupLanguageParser (defined by the Treetop source).
    def initialize
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    # Compile source code into an array of Translation objects, 
    # throwing an exception if there is a parse error.
    def compile_translations(markup)
      syntax_tree = @parser.parse(markup, root: :translations)
      if(syntax_tree.nil?)
        raise Exception, "Parse error: #{@parser.failure_reason}"
      end
      syntax_tree.value
    end
  end
  
end
