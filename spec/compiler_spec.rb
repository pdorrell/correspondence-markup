require 'correspondence-ml'

describe "markup language compilation" do
  
  before(:all) do
    @parser = CorrespondenceMarkupLanguageParser.new
  end
  
  def parse(string, root = :structure_group)
    @parser.parse(string, root: root)
  end
  
  it "compiles number" do
    parse("234", :number).value.should == 234
  end
  
end
