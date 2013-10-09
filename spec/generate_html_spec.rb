# -*- coding: utf-8 -*-

require 'correspondence-markup'
require 'spec_helper'
require 'erb'
require 'cgi'

module CorrespondenceMarkup

  describe "generating HMTL" do
    
    it "splits tags and text in HTML" do
      Helpers.split_tags_and_text(" no tags").should == [[nil, " no tags"]]
      Helpers.split_tags_and_text("<tag> something else<another attr=\"value\"> more").should == 
        [["<tag>", nil], 
         [nil, " something else"], 
         ["<another attr=\"value\">", nil], 
         [nil, " more"]]
      Helpers.split_tags_and_text("not tag<tag><2nd tag> and <unfinished").should == 
        [[nil, "not tag"], 
         ["<tag>", nil], 
         ["<2nd tag>", nil], 
         [nil, " and "], 
         ["<unfinished", nil]]
    end
    
    it "generates HTML for an item" do
      item = Item.new("3,21", "the text with &lt;")
      item.to_html.should == output_file_contents("item.html")
      item.to_html(escaped: true).should == output_file_contents("item.escaped.html")
    end
    
    it "generates HTML for a non-item" do
      nonItem = NonItem.new("some text with &lt;")
      nonItem.to_html.should == output_file_contents("nonItem.html")
      nonItem.to_html(escaped: true).should == output_file_contents("nonItem.escaped.html")
    end
    
    it "inserts br element with br: option" do
      nonItem = NonItem.new("two\nlines")
      nonItem.to_html.should == "two\nlines"
      nonItem.to_html(br: true).should == "two<br/>lines"
      structureGroup = StructureGroup.new(nil, 
                                          [Structure.new("english", "English", 
                                                         [ItemGroup.new("A", [NonItem.new("a\nb")])])])
      structureGroup.to_html.should == "<div class=\"translation\">\n" + 
        "  <div class=\"block english-block\">\n" + 
        "    <div class=\"language\">English</div>\n" + 
        "    <div class=\"line\" data-group-id=\"A\">\n" +
        "      a\n    b\n    </div>\n  </div>\n</div>\n"
      structureGroup.to_html(br: true).should == "<div class=\"translation\">\n" + 
        "  <div class=\"block english-block\">\n" + 
        "    <div class=\"language\">English</div>\n" + 
        "    <div class=\"line\" data-group-id=\"A\">\n" +
        "      a<br/>b\n    </div>\n  </div>\n</div>\n"
    end
    
    it "non-item outputs spaces as nbsp with nbsp: option" do
      nonItem = NonItem.new("  two\nlines  with spaces")
      nonItem.to_html(nbsp: true).should == "&nbsp;&nbsp;two\nlines&nbsp;&nbsp;with&nbsp;spaces"
      nonItem.to_html(nbsp: true, br: true).should == "&nbsp;&nbsp;two<br/>lines&nbsp;&nbsp;with&nbsp;spaces"
    end
    
    it "nbsp option does not replace spaces inside HTML tags" do
      nonItem = NonItem.new("<span class=\"myClass\">hello word</span>")
      nonItem.to_html.should == "<span class=\"myClass\">hello word</span>"
   #   nonItem.to_html(nbsp:true).should == "<span class=\"myClass\">hello&nbsp;word</span>"
    end
    
    
    it "item outputs spaces as nbsp with nbsp: option" do
      item = Item.new(3, " text with\nspaces ")
      item.to_html.should == "<span data-id=\"3\"> text with\nspaces </span>"
      item.to_html(br: true).should == "<span data-id=\"3\"> text with<br/>spaces </span>"
      item.to_html(nbsp: true).should == "<span data-id=\"3\">&nbsp;text&nbsp;with\nspaces&nbsp;</span>"
      item.to_html(nbsp: true, br: true).should == "<span data-id=\"3\">&nbsp;text&nbsp;with<br/>spaces&nbsp;</span>"
    end     
    
    it "generates HTML for a structure" do
      structure = Structure.new("", "English", 
                                [ItemGroup.new("A", [Item.new(1, "Hello"), 
                                                     NonItem.new(", "), 
                                                     Item.new(2, "World")])])
      structure.to_html.should == output_file_contents("structure.html")
    end
    
    it "generates HTML for a structure with br and/or nbsp option" do
      structure = Structure.new("", nil, 
                                [ItemGroup.new("A", [Item.new(1, "Good Morning"), 
                                                         NonItem.new(" ,\n"), 
                                                         Item.new(2, " World")])])
      structure.to_html.should == output_file_contents("structure.goodmorning.html")
      structure.to_html(br: true).should == output_file_contents("structure.goodmorning.br.html")
      structure.to_html(nbsp: true).should == output_file_contents("structure.goodmorning.nbsp.html")
      structure.to_html(br: true, nbsp: true).should == output_file_contents("structure.goodmorning.br.nbsp.html")
    end
    
    it "generates HTML for a structure group" do
      structure1 = Structure.new("", nil, [ItemGroup.new("A", [Item.new(1, "Hello"), 
                                                               NonItem.new(", "), 
                                                               Item.new(2, "World"), 
                                                               NonItem.new("!")])])
      structure2 = Structure.new("spanish", "Spanish",
                                 [ItemGroup.new("A", [NonItem.new("¡"), 
                                                      Item.new(1, "Hola"), 
                                                      NonItem.new(", "), 
                                                      Item.new(2, "Mundo"), 
                                                      NonItem.new("!")])])
      structureGroup = StructureGroup.new("Description of the group", [structure1, structure2])
      structureGroup.to_html.should == output_file_contents("structureGroup.html")
    end
    
    it "generates HTML for a structure group with br/nbsp in first structure" do
      structure1 = Structure.new("", nil, [ItemGroup.new("A", [Item.new(1, "Good Morning"), 
                                                               NonItem.new(" , \n"), 
                                                               Item.new(2, " World"), 
                                                               NonItem.new("!")])])
      structure2 = Structure.new("", nil, [ItemGroup.new("A", [NonItem.new("¡"), 
                                                               Item.new(1, "Buenas Dias"), 
                                                               NonItem.new(", \n"), 
                                                               Item.new(2, "Mundo"), 
                                                               NonItem.new("!")])])
      structureGroup = StructureGroup.new(nil, [structure1, structure2])
      structureGroup.to_html.should == output_file_contents("goodMorningBuenasDias.html")
      structureGroup.to_html(br: [true, false], nbsp: [true, false]).should == output_file_contents("goodMorningBuenasDias.br.nbsp.html")
    end
  end
end
