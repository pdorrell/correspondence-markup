require 'correspondence-ml'

describe "markup language grammar" do
  
  before(:all) do
    @parser = CorrespondenceMarkupLanguageParser.new
  end
  
  def parse_number(string)
    @parser.parse(string, root: :number)
  end
  
  def should_parse(root, strings)
    for string in strings
      @parser.parse(string, root: root).should_not be_nil
    end
  end
  
  def should_not_parse(root, strings)
    for string in strings
      @parser.parse(string, root: root).should be_nil
    end
  end
  
  it "parses number with one or more decimal digits only" do
    should_parse(:number, ["45", "5", "6677", "99999988"])
    should_not_parse(:number, ["", "-45", "6 7", "jim"])
  end
  
end
