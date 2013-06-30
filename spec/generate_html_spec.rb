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
      template = ERB.new(template_text, nil, "-")
      html = template.result(template_binding)
      puts "output HTML #{html.inspect}"
      html
    end

    it "generates HTML for an item" do
      item = Item.new(21, "the text with &lt;")
      item.to_html.should match_as_html output_file_contents("item.generated.html")
    end
    
    it "generates HTML for a non-item" do
      nonItem = NonItem.new("some text with &lt;")
      nonItem.to_html.should match_as_html output_file_contents("nonItem.generated.html")
    end
    

    it "generates HTML for a structure" do
      structure = Structure.new([Item.new(1, "Hello"), 
                                 NonItem.new(", "), 
                                 Item.new(2, "World")])
      structure.to_html.should match_as_html output_file_contents("structure.generated.html")
    end
    
  end
end
