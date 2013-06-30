require 'correspondence-markup'
require 'erb'

module CorrespondenceMarkup

  describe "generating HMTL" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def output_html(template_binding, template_text)
      template = ERB.new(template_text, nil, nil)
      template.result(template_binding)
    end

    it "outputs HTML for an item" do
      item_template_filename = File.join(File.dirname(__FILE__), "templates", "item.html.erb")
      item_template = File.read(item_template_filename)
      item = Item.new(21, "the text")
      output_html(binding, item_template).should == %{<span data-id="21">the text</span>}
    end
    
  end
end
