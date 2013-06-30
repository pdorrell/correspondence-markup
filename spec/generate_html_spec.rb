require 'correspondence-markup'
require 'spec_helper'
require 'erb'
require 'cgi'

module CorrespondenceMarkup

  describe "generating HMTL" do
    

    it "generates HTML for an item" do
      item = Item.new(21, "the text with &lt;")
      item.to_html.should == output_file_contents("item.generated.html")
    end
    
    it "generates HTML for a non-item" do
      nonItem = NonItem.new("some text with &lt;")
      nonItem.to_html.should == output_file_contents("nonItem.generated.html")
    end
    

    it "generates HTML for a structure" do
      structure = Structure.new([Item.new(1, "Hello"), 
                                 NonItem.new(", "), 
                                 Item.new(2, "World")])
      structure.to_html.should == output_file_contents("structure.generated.html")
    end
    
    it "generates HTML for a structure group" do
      structure1 = Structure.new([Item.new(1, "Hello"), 
                                 NonItem.new(", "), 
                                 Item.new(2, "World")])
      structure2 = Structure.new([Item.new(1, "Hola"), 
                                 NonItem.new(", "), 
                                 Item.new(2, "Mundo")])
      structureGroup = StructureGroup.new([structure1, structure2])
      structureGroup.to_html.should == output_file_contents("structureGroup.generated.html")
    end
    
  end
end
