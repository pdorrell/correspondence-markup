require 'polyglot'
require 'treetop'

require 'correspondence-markup/bracketed-grammar'

module CorrespondenceMarkup
  
  # Compiler than parses and compiles correspondence markup source code 
  # into an array of StructureGroup objects (from which HTML can be
  # generated in the format required by correspondence.js)
  class CorrespondenceMarkupCompiler
    
    # initialize by creating the CorrespondenceMarkupLanguageParser (defined by the Treetop source)
    def initialize
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    # compile source code into an array of StructureGroups, 
    # throwing an exception if there is a parse error
    def compile_structure_groups(markup)
      syntax_tree = @parser.parse(markup, root: :structure_groups)
      if(syntax_tree.nil?)
        raise Exception, "Parse error: #{@parser.failure_reason}"
      end
      syntax_tree.value
    end
  end
  
end
