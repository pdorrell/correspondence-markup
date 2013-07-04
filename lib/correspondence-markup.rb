require 'polyglot'
require 'treetop'

require 'correspondence-markup/bracketed-grammar'

module CorrespondenceMarkup
  
  class CorrespondenceMarkupCompiler
    def initialize
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def compile_structure_groups(markup)
      syntax_tree = @parser.parse(markup, root: :structure_groups)
      if(syntax_tree.nil?)
        raise Exception, "Parse error: #{@parser.failure_reason}"
      end
      syntax_tree.value
    end
  end
  
  def self.sayHello
    "hello"
  end
  
end
