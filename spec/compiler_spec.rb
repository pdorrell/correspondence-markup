require 'correspondence-markup'

module CorrespondenceMarkup

  describe "markup language compilation" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def parse(string, root = :structure_group)
      #puts "parsing #{string.inspect} ..."
      @parser.parse(string, root: root)
    end
    
    it "compiles number" do
      parse("234", :number).value.should == 234
    end
    
    it "compiles item" do
      parse("[31 text]", :item).value.should == Item.new(31, "text")
    end
    
    it "compiles non-item" do
      parse("anything at all", :non_item).value.should == NonItem.new("anything at all")
    end
    
    it "compiles structure" do
      parse("[1 an item] in between stuff [2 a second item]", :structure).value.should == 
        Structure.new([Item.new(1, "an item"), NonItem.new(" in between stuff "), 
                       Item.new(2, "a second item")])
    end
    
    it "compiles structure group" do
      expectedStructureGroup = 
        StructureGroup.new([
                            Structure.new([Item.new(1, "Hello"), NonItem.new(" in between stuff "), 
                                           Item.new(2, "world")]), 
                            Structure.new([Item.new(1, "Hola"), NonItem.new("  "), 
                                           Item.new(2, "mundo")])
                            ]);
      parse(" [[1 Hello] in between stuff [2 world]] [[1 Hola]  [2 mundo]] ", 
            :structure_group).value.should == expectedStructureGroup
      parse(" [[1 Hello] in between stuff [2 world]][[1 Hola]  [2 mundo]] ", 
            :structure_group).value.should == expectedStructureGroup
      parse("[[1 Hello] in between stuff [2 world]][[1 Hola]  [2 mundo]]",
            :structure_group).value.should == expectedStructureGroup
        
    end
    
    it "compiles structure groups" do
      expectedStructureGroups = 
        [StructureGroup.new([
                            Structure.new([Item.new(1, "Hello"), NonItem.new(" in between stuff "), 
                                           Item.new(2, "world")]), 
                            Structure.new([Item.new(1, "Hola"), NonItem.new("  "), 
                                           Item.new(2, "mundo")])
                            ]), 
         StructureGroup.new([
                             Structure.new([Item.new(3, "3"), NonItem.new(" "), Item.new(4, "+"), NonItem.new(" "), 
                                            Item.new(5, "4"), NonItem.new(" "), Item.new(6, "="), NonItem.new(" "), 
                                            Item.new(7, "7")]), 
                             Structure.new([Item.new(3, "three"), NonItem.new(" "), Item.new(4, "and"), NonItem.new(" "), 
                                            Item.new(5, "four"), NonItem.new(" "), Item.new(6, "makes"), NonItem.new(" "), 
                                            Item.new(7, "seven")])
                            ])]
      
      parse(%{
              [ [[1 Hello] in between stuff [2 world]]
                [[1 Hola]  [2 mundo]] ]
              [ [[3 3] [4 +] [5 4] [6 =] [7 7]]
                [[3 three] [4 and] [5 four] [6 makes] [7 seven]] ]
             }, :structure_groups).value.should == expectedStructureGroups
                             
    end
    
  end

end
