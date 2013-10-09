require 'correspondence-markup/types'

module CorrespondenceMarkup
  describe 'corresondence markup types' do
    
    describe 'Item type' do
      it "item has id and text attribute" do
        item = Item.new(34, "text")
        item.id.should == 34
        item.text.should == "text"
      end
      
      it "items with same number and text are equal" do
        item = Item.new(34, "text")
        item.should == item
        item.should == Item.new(34, "text")
        item.should_not == "something else"
        item.should_not == Item.new(35, "text")
        item.should_not == Item.new(34, "different text")
        item.should_not == Item.new(35, "different text")
      end
    end
    
    describe 'NonItem type' do
      it 'non-item has text attribute' do
        nonItem = NonItem.new("the text")
        nonItem.text.should == "the text"
      end
      
      it "non-items with same text are equal" do
        nonItem = NonItem.new("the text")
        nonItem.should == nonItem
        nonItem.should == NonItem.new("the text")
        nonItem.should_not == "something else"
        nonItem.should_not == NonItem.new("different text")
      end
        
    end
    
    describe "Line type" do
      it "line has id and content attribute" do
        line = Line.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        line.id.should == "A"
        line.content.should == [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]
      end
      
      it "line is equal to a line with the same id and content" do
        line = Line.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        line.should_not == "something else"
        line.should == Line.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        line.should_not == Line.new("B", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        line.should_not == Line.new("A", [Item.new(1, "hello"), NonItem.new("space"), Item.new(2, "world")])
        line.should_not == Line.new("A", [Item.new(1, "hello"), NonItem.new(" ")])        
        line.should_not == Line.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(3, "world")])
      end
    end
    
    describe "Block type" do
      it "block has type and lines attribute" do
        block = Block.new("english", 
                          "English", 
                          [Line.new("D", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        block.languageId.should == "english"
        block.languageTitle.should == "English"
        block.lines.should == [Line.new("D", [Item.new(1, "hello"), 
                                              NonItem.new(" "), Item.new(2, "world")])]
      end
      
      it "block is equal to a block with the same lines" do
        block = Block.new("english", "English", 
                          [Line.new("D", 
                                    [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        block.should_not == "something else"
        block.should_not == Block.new("english", "Spanish", 
                                      [Line.new("D", 
                                                [Item.new(1, "hello"), NonItem.new(" "), 
                                                 Item.new(2, "world")])])
        block.should_not == Block.new("spanish", "English", 
                                      [Line.new("D", 
                                                [Item.new(1, "hello"), NonItem.new(" "), 
                                                 Item.new(2, "world")])])
         block.should == Block.new("english", "English", 
                                   [Line.new("D", 
                                             [Item.new(1, "hello"), NonItem.new(" "), 
                                              Item.new(2, "world")])])
        block.should_not == Block.new("english", "English", 
                                      [Line.new("D", 
                                                [Item.new(1, "hello"), NonItem.new("space"), 
                                                 Item.new(2, "world")])])
        block.should_not == Block.new("english", "English", 
                                      [Line.new("D", 
                                                [Item.new(1, "hello"), NonItem.new(" ")])])
        block.should_not == Block.new("english", "English", 
                                      [Line.new("D", 
                                                [Item.new(1, "hello"), NonItem.new(" "), 
                                                 Item.new(3, "world")])])
      end
    end
    
    describe "Translation type" do
      it "translation has title and blocks attributes" do
        translation = 
          Translation.new("Saying hello", 
                          [Block.new("english", "English", 
                                     [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                           Block.new("spanish", "Spanish", 
                                     [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        translation.title.should == "Saying hello"
        translation.blocks[1].should == 
          Block.new("spanish", "Spanish", [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])
      end
      
      it "translations are equal if their content is equal" do
        translation = 
          Translation.new("Hello", 
                          [Block.new("english", "English", 
                                     [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                           Block.new("spanish", "Spanish", 
                                     [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        identicalTranslation = 
          Translation.new("Hello", 
                          [Block.new("english", "English",
                                     [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                           Block.new("spanish", "Spanish", 
                                     [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        notQuiteTheSameTranslation = 
          Translation.new("Hello", 
                          [Block.new("english", "English", 
                                     [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                           Block.new("spanish", "Spanish", 
                                     [Item.new(1, "Holla"), NonItem.new(" "), Item.new(2, "mundo")])])
        differentlyDescribedTranslation = 
          Translation.new("goodbye", 
                             translation.blocks)
        translation.should == translation
        translation.should == identicalTranslation
        translation.should_not == "something else"
        translation.should_not == notQuiteTheSameTranslation
        translation.should_not == differentlyDescribedTranslation.should_not
      end
    end
    
  end
end
