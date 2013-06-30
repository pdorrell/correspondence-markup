require 'correspondence-markup'
require 'erb'

module CorrespondenceMarkup

  describe "generating HMTL" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def output_html(object_binding, template_text)
      template = ERB.new(template_text, nil, nil)
      template.result(object_binding)
    end

    it "outputs HTML for an item" do
      item_template = %{<span data-id="<%=item.id%>"><%=item.text%></span>}
      item = Item.new(21, "the text")
      @binding = binding
      output_html(@binding, item_template).should == %{<span data-id="21">the text</span>}
    end
  end
end
