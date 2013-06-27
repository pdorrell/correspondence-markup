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
    
  end

end
