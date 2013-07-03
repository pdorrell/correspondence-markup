# -*- coding: utf-8 -*-

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
    
    it "inserts br element with br: option" do
      nonItem = NonItem.new("two\nlines")
      nonItem.to_html.should == "two\nlines"
      nonItem.to_html(br: true).should == "two<br/>lines"
      structureGroup = StructureGroup.new([Structure.new([NonItem.new("a\nb")])])
      structureGroup.to_html.should == "<div class=\"structure-group\">\n" + 
        "  <div class=\"structure\">\n    a\n  b\n  </div>\n</div>\n"
      structureGroup.to_html(br: true).should == "<div class=\"structure-group\">\n" + 
        "  <div class=\"structure\">\n    a<br/>b\n  </div>\n</div>\n"
    end
    
    it "non-item outputs spaces as nbsp with nbsp: option" do
      nonItem = NonItem.new("  two\nlines  with spaces")
      nonItem.to_html(nbsp: true).should == "&nbsp;&nbsp;two\nlines&nbsp;&nbsp;with&nbsp;spaces"
      nonItem.to_html(nbsp: true, br: true).should == "&nbsp;&nbsp;two<br/>lines&nbsp;&nbsp;with&nbsp;spaces"
    end
    
    it "item outputs spaces as nbsp with nbsp: option" do
      item = Item.new(3, " text with\nspaces ")
      item.to_html.should == "<span data-id=\"3\"> text with\nspaces </span>"
      item.to_html(br: true).should == "<span data-id=\"3\"> text with<br/>spaces </span>"
      item.to_html(nbsp: true).should == "<span data-id=\"3\">&nbsp;text&nbsp;with\nspaces&nbsp;</span>"
      item.to_html(nbsp: true, br: true).should == "<span data-id=\"3\">&nbsp;text&nbsp;with<br/>spaces&nbsp;</span>"
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
                                 Item.new(2, "World"), 
                                 NonItem.new("!")])
      structure2 = Structure.new([NonItem.new("¡"), 
                                  Item.new(1, "Hola"), 
                                  NonItem.new(", "), 
                                  Item.new(2, "Mundo"), 
                                  NonItem.new("!")])
      structureGroup = StructureGroup.new([structure1, structure2])
      structureGroup.to_html.should == output_file_contents("structureGroup.generated.html")
    end
    
  end
end
