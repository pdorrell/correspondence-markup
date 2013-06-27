require 'correspondence-ml'

describe "markup language grammar" do
  it "parses number with decimal digits only" do
    parser = CorrespondenceMarkupLanguageParser.new
    parser.parse("45", root: :number).should_not be_nil
  end
  
  it "doesn't parses any string with non-decimal digits" do
    parser = CorrespondenceMarkupLanguageParser.new
    parser.parse("jim", root: :number).should be_nil
    parser.parse("-45", root: :number).should be_nil
    parser.parse("26e", root: :number).should be_nil
  end
  
  it "doesn't parse an empty string" do
    parser = CorrespondenceMarkupLanguageParser.new
    parser.parse("", root: :number).should be_nil
  end
  
end
