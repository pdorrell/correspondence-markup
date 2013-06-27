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
        Item.new(34, "text").should == Item.new(34, "text")
        Item.new(34, "text").should_not == "something else"
        Item.new(34, "text").should_not == Item.new(35, "text")
        Item.new(34, "text").should_not == Item.new(34, "different text")
        Item.new(34, "text").should_not == Item.new(35, "different text")
      end
    end
    
    describe 'NonItem type' do
      it 'non-item has text attribute' do
        nonItem = NonItem.new("the text")
        nonItem.text.should == "the text"
      end
    end
    
  end
end
