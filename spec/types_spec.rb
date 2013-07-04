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
      it "structure has item_groups attribute" do
        structure = Structure.new([ItemGroup.new("D", [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        structure.item_groups.should == [ItemGroup.new("D", [Item.new(1, "hello"), 
                                                             NonItem.new(" "), Item.new(2, "world")])]
      end
      
      it "structure is equal to a structure with the same item_groups" do
        structure = Structure.new([ItemGroup.new("D", 
                                                 [Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")])])
        structure.should_not == "something else"
        structure.should == Structure.new([ItemGroup.new("D", 
                                                         [Item.new(1, "hello"), NonItem.new(" "), 
                                                          Item.new(2, "world")])])
        structure.should_not == Structure.new([ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new("space"), 
                                                              Item.new(2, "world")])])
        structure.should_not == Structure.new([ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" ")])])
        structure.should_not == Structure.new([ItemGroup.new("D", 
                                                             [Item.new(1, "hello"), NonItem.new(" "), 
                                                              Item.new(3, "world")])])
      end
    end
    
    describe "StructureGroup type" do
      it "structure group has structures attribute" do
        structureGroup = 
          StructureGroup.new([Structure.new([Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new([Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        structureGroup.structures[1].should == 
          Structure.new([Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])
      end
      
      it "structure groups are equal if their content is equal" do
        structureGroup = 
          StructureGroup.new([Structure.new([Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new([Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        identicalGroup = 
          StructureGroup.new([Structure.new([Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new([Item.new(1, "Hola"), NonItem.new(" "), Item.new(2, "mundo")])])
        notQuiteTheSameGroup = 
          StructureGroup.new([Structure.new([Item.new(1, "hello"), NonItem.new(" "), Item.new(2, "world")]), 
                              Structure.new([Item.new(1, "Holla"), NonItem.new(" "), Item.new(2, "mundo")])])
        structureGroup.should == structureGroup
        structureGroup.should == identicalGroup
        structureGroup.should_not == "something else"
        structureGroup.should_not == notQuiteTheSameGroup
      end
    end
    
  end
end
