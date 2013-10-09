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
    
    describe "ItemGroup type" do
      it "item group has id and content attribute" do
        itemGroup = ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        itemGroup.id.should == "A"
        itemGroup.content.should == [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]
      end
      
      it "itemGroup is equal to a itemGroup with the same id and content" do
        itemGroup = ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        itemGroup.should_not == "something else"
        itemGroup.should == ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        itemGroup.should_not == ItemGroup.new("B", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])
        itemGroup.should_not == ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new("space"), Item.new(2, "world")])
        itemGroup.should_not == ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new(" ")])        
        itemGroup.should_not == ItemGroup.new("A", [Item.new(1, "hello"), NonItem.new(" "), Item.new(3, "world")])
      end
    end
    
    describe "Structure type" do
      it "structure has type and item_groups attribute" do
        structure = Structure.new("english", 
                                  "English", 
                                  [ItemGroup.new("D", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        structure.type.should == "english"
        structure.description.should == "English"
        structure.item_groups.should == [ItemGroup.new("D", [Item.new(1, "hello"), 
                                                             NonItem.new(" "), Item.new(2, "world")])]
      end
      
      it "structure is equal to a structure with the same item_groups" do
        structure = Structure.new("english", "English", 
                                  [ItemGroup.new("D", 
                                                 [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        structure.should_not == "something else"
        structure.should_not == Structure.new("english", "Spanish", 
                                              [ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" "), 
                                                              Item.new(2, "world")])])
        structure.should_not == Structure.new("spanish", "English", 
                                              [ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" "), 
                                                              Item.new(2, "world")])])
         structure.should == Structure.new("english", "English", 
                                           [ItemGroup.new("D", 
                                                         [Item.new(1, "hello"), NonItem.new(" "), 
                                                          Item.new(2, "world")])])
        structure.should_not == Structure.new("english", "English", 
                                              [ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new("space"), 
                                                              Item.new(2, "world")])])
        structure.should_not == Structure.new("english", "English", 
                                              [ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" ")])])
        structure.should_not == Structure.new("english", "English", 
                                              [ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" "), 
                                                              Item.new(3, "world")])])
      end
    end
    
    describe "Translation type" do
      it "translation has description and structures attributes" do
        translation = 
          Translation.new("Saying hello", 
                             [Structure.new("english", "English", 
                                            [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new("spanish", "Spanish", 
                                            [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        translation.description.should == "Saying hello"
        translation.structures[1].should == 
          Structure.new("spanish", "Spanish", [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])
      end
      
      it "translations are equal if their content is equal" do
        translation = 
          Translation.new("Hello", 
                             [Structure.new("english", "English", 
                                            [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new("spanish", "Spanish", 
                                            [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        identicalGroup = 
          Translation.new("Hello", 
                             [Structure.new("english", "English",
                                            [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new("spanish", "Spanish", 
                                            [Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        notQuiteTheSameGroup = 
          Translation.new("Hello", 
                             [Structure.new("english", "English", 
                                            [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new("spanish", "Spanish", 
                                            [Item.new(1, "Holla"), NonItem.new(" "), Item.new(2, "mundo")])])
        differentlyDescribedGroup = 
          Translation.new("goodbye", 
                             translation.structures)
        translation.should == translation
        translation.should == identicalGroup
        translation.should_not == "something else"
        translation.should_not == notQuiteTheSameGroup
        translation.should_not == differentlyDescribedGroup.should_not
      end
    end
    
  end
end
