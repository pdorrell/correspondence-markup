require 'correspondence-markup'
require 'spec_helper'

module CorrespondenceMarkup

  describe "markup language compilation and HTML generation" do
    
    before(:all) do
      @compiler = CorrespondenceMarkupCompiler.new
    end
    
    it "compiles structure groups and generates HTML" do
      structure_groups_markup = input_file_contents("structureGroups.corrml")
      structure_groups = @compiler.compile_structure_groups(structure_groups_markup)
      structure_groups_html = structure_groups.map(&:to_html).join "\n"
      structure_groups_html.should == output_file_contents("structureGroups.compiled.html")
    end
  end
end

