require 'correspondence-ml/types'

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
    
  end
end
