require 'correspondence-ml'

module CorrespondenceMarkup

  describe "markup language compilation" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def parse(string, root = :structure_group)
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
      parse("[[1 an item] in between stuff [2 a second item]]", :structure).value.should == 
        Structure.new([Item.new(1, "an item"), NonItem.new(" in between stuff "), 
                       Item.new(2, "a second item")])
      
    end
    
  end

end
