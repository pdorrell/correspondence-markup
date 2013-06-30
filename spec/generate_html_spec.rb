require 'correspondence-markup'
require 'erb'

module CorrespondenceMarkup

  describe "generating HMTL" do
    
    before(:all) do
      @parser = CorrespondenceMarkupLanguageParser.new
    end
    
    def test_template(base_filename)
      template_filename = File.join(File.dirname(__FILE__), "templates", base_filename)
      File.read(template_filename)
    end

    def test_output_from_file(base_filename)
      output_filename = File.join(File.dirname(__FILE__), "output", base_filename)
      File.read(output_filename)
    end

    def output_html(template_binding, template_text)
      template = ERB.new(template_text, nil, nil)
      template.result(template_binding)
    end

    it "outputs HTML for an item" do
      item_template = test_template("item.html.erb")
      item = Item.new(21, "the text")
      output_html(binding, item_template).should == test_output_from_file("item.output.html")
    end
    
  end
end
