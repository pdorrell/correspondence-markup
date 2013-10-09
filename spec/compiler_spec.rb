require 'correspondence-markup'

module CorrespondenceMarkup

  describe "markup language compilation" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def parse(string, root = :translation)
      #puts "parsing #{string.inspect} ..."
      @parser.parse(string, root: root)
    end
    
    it "compiles text" do
      parse("some text", :text).value.should == "some text"
      parse("two\nlines", :text).value.should == "two\nlines"
    end
    
    it "compiles item_id" do
      parse("234", :item_id).text_value.should == "234"
      parse("A234", :item_id).text_value.should == "A234"
    end
    
    it "compiles item" do
      parse("[31 text]", :item).value.should == Item.new("31", "text")
      parse("[B31 text]", :item).value.should == Item.new("B31", "text")
    end
    
    it "compiles non-item" do
      parse("anything at all", :non_item).value.should == NonItem.new("anything at all")
    end
    
    it "compiles with backslash quoting" do
      parse("a\\[23\\] = b \\\\ c", :text).value.should == "a[23] = b \\ c"
      parse("a\\[23\\] = b \\\\ c", :non_item).value.should == NonItem.new("a[23] = b \\ c")
      parse("[31 a\\[23\\] = c]", :item).value.should == Item.new("31", "a[23] = c")
    end  
    
    it "compiles with backslash quoting, matching forward only (no overlaps)" do
      parse("\\[\\\\\\\\\\]", :text).value.should == "[\\\\]"
    end
    
    it "compiles item group" do
      parse("[1 an item] in between stuff [2 a second item]", :item_group).value.should == 
        ItemGroup.new("", [Item.new("1", "an item"), NonItem.new(" in between stuff "), 
                           Item.new("2", "a second item")])
      parse("A:[1 an item] in between stuff [2 a second item]", :item_group).value.should == 
        ItemGroup.new("A", [Item.new("A1", "an item"), NonItem.new(" in between stuff "), 
                            Item.new("A2", "a second item")])
    end
    
    it "does not add group id if item id has alphabetic" do
      parse("A:[1 an item] in between stuff [B2 a second item]", :item_group).value.should == 
        ItemGroup.new("A", [Item.new("A1", "an item"), NonItem.new(" in between stuff "), 
                            Item.new("B2", "a second item")])
    end
    
    it "parses item group with multiple IDs, adding group IDs as required" do
      parse("A:[1,B3,2 an item] in between stuff [B2,4,5 a second item]", :item_group).value.should == 
        ItemGroup.new("A", [Item.new("A1,B3,A2", "an item"), NonItem.new(" in between stuff "), 
                            Item.new("B2,A4,A5", "a second item")])
    end
      
    
    it "compiles structure" do
      structureNode = parse("[A:[1 an item] in between stuff [2 a second item]]", :structure)
      structureNode.value.should == 
        Structure.new("", nil, 
                      [ItemGroup.new("A", [Item.new("A1", "an item"), NonItem.new(" in between stuff "), 
                                           Item.new("A2", "a second item")])])
    end
    
    it "compiles structure with CSS class" do
      structureNode = parse("english: English\n [A:[1 an item] in between stuff [2 a second item]]", :structure)
      structureNode.value.should == 
        Structure.new("english", "English", 
                      [ItemGroup.new("A", [Item.new("A1", "an item"), NonItem.new(" in between stuff "), 
                                           Item.new("A2", "a second item")])])
    end
    
    it "compiles structure group" do
      expectedTranslation = 
        Translation.new("example", [
                            Structure.new("english", "English", 
                                          [ItemGroup.new("", 
                                                         [Item.new("1", "Hello"), NonItem.new(" in between stuff "), 
                                                          Item.new("2", "world")])]), 
                            Structure.new("spanish", "Spanish", 
                                          [ItemGroup.new("", 
                                                         [Item.new("1", "Hola"), NonItem.new("  "), 
                                                          Item.new("2", "mundo")])])
                           ]);
      parse("#example\n{english: English\n [[1 Hello] in between stuff [2 world]]} {spanish: Spanish\n [[1 Hola]  [2 mundo]]} ", 
            :translation).value.should == expectedTranslation
      parse("#example\n {english:  English\n [[1 Hello] in between stuff [2 world]]}{spanish: Spanish\n [[1 Hola]  [2 mundo]] }", 
            :translation).value.should == expectedTranslation
      parse("#example\n{english: English\n [[1 Hello] in between stuff [2 world]]}{spanish: Spanish\n [[1 Hola]  [2 mundo]]}",
            :translation).value.should == expectedTranslation
        
    end
    
    it "compiles structure groups" do
      expectedTranslations = 
        [Translation.new(nil, 
                            [Structure.new("english", "English", 
                                           [ItemGroup.new("", 
                                                          [Item.new("1", "Hello"), NonItem.new(" in between stuff "), 
                                                           Item.new("2", "world")])]), 
                             Structure.new("spanish", nil, 
                                           [ItemGroup.new("", 
                                                          [Item.new("1", "Hola"), NonItem.new("  "), 
                                                           Item.new("2", "mundo")])])
                            ]), 
         Translation.new(nil, 
                            [Structure.new("equation", "Mathematical Equation", 
                                           [ItemGroup.new("", 
                                                          [Item.new("3", "3"), NonItem.new(" "), Item.new("4", "+"), 
                                                           NonItem.new(" "), Item.new("5", "4"), NonItem.new(" "), 
                                                           Item.new("6", "="), NonItem.new(" "), Item.new("7", "7")])]), 
                             Structure.new("english", "English", 
                                           [ItemGroup.new("", 
                                                          [Item.new("3", "three"), NonItem.new(" "), Item.new("4", "and"), 
                                                           NonItem.new(" "), Item.new("5", "four"), NonItem.new(" "), 
                                                           Item.new("6", "makes"), NonItem.new(" "), 
                                                           Item.new("7", "seven")])])
                            ])]
      
      parse(%{
              ( {english: English
                 [[1 Hello] in between stuff [2 world]]}
                {spanish [[1 Hola]  [2 mundo]]} )
              ( {equation: Mathematical Equation
                 [[3 3] [4 +] [5 4] [6 =] [7 7]]}
                {english: English
                 [[3 three] [4 and] [5 four] [6 makes] [7 seven]]} )
             }, :translations).value.should == expectedTranslations
                             
    end
    
  end

end
