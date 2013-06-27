require 'correspondence-ml'

describe "markup language grammar" do
  
  before(:all) do
    @parser = CorrespondenceMarkupLanguageParser.new
  end
  
  it "parses number with one or more decimal digits only" do
    @parser.parse("45", root: :number).should_not be_nil
  end
  
  it "doesn't parses any string with non-decimal digits" do
    @parser.parse("jim", root: :number).should be_nil
    @parser.parse("-45", root: :number).should be_nil
    @parser.parse("26e", root: :number).should be_nil
  end
  
  it "doesn't parse an empty string" do
    @parser.parse("", root: :number).should be_nil
  end
  
end
