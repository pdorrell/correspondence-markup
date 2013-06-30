require 'correspondence-markup'
require 'spec_helper'
require 'erb'
require 'cgi'

module CorrespondenceMarkup

  describe "generating HMTL" do
    
    def h(text)
      CGI.escape_html(text)
    end
    
    def test_template(base_filename)
      template_filename = File.join(File.dirname(__FILE__), "templates", base_filename)
      File.read(template_filename)
    end

    def output_file_contents(base_filename)
      output_filename = File.join(File.dirname(__FILE__), "output", base_filename)
      File.read(output_filename)
    end

    def output_html(template_binding, template_text)
      template = ERB.new(template_text, nil, ">")
      template.result(template_binding)
    end

    it "outputs HTML for an item" do
      item_template = test_template("item.html.erb")
      item = Item.new(21, "the text with &lt;")
      output_html(binding, item_template).should match_as_html output_file_contents("item.output.html")
    end

    it "outputs HTML for a structure" do
      structure_template = test_template("structure.html.erb")
      structure = Structure.new([Item.new(1, "Hello"), 
                                 NonItem.new(", "), 
                                 Item.new(2, "World")])
      output_html(binding, structure_template).should match_as_html output_file_contents("structure.output.html")
    end
    
  end
end
