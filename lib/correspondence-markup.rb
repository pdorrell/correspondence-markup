require 'polyglot'
require 'treetop'

require 'correspondence-markup/bracketed-grammar'

module CorrespondenceMarkup
  
  class CorrespondenceMarkupCompiler
    def initialize
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def compile_structure_groups(markup)
      @parser.parse(markup, root: :structure_groups).value
    end
  end
  
  def self.sayHello
    "hello"
  end
  
end
