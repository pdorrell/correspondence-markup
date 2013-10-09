require 'correspondence-markup'
require 'spec_helper'

module CorrespondenceMarkup

  describe "markup language compilation and HTML generation" do
    
    before(:all) do
      @compiler = CorrespondenceMarkupCompiler.new
    end
    
    it "compiles structure groups and generates HTML" do
      translations_markup = input_file_contents("translations.corrml")
      translations = @compiler.compile_translations(translations_markup)
      translations_html = translations.map(&:to_html).join "\n"
      translations_html.should == output_file_contents("translations.compiled.html")
    end
  end
end

