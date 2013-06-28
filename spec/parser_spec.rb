require 'correspondence-ml'

require 'spec_helper'

describe "markup language grammar" do

  def should_parse(root, strings)
    parser = CorrespondenceMarkupLanguageParser.new
    for string in strings
      process("parsing #{string.inspect}") do
        parser.parse(string, root: root).should_not be_nil
      end
    end
  end
  
  def should_not_parse(root, strings)
    parser = CorrespondenceMarkupLanguageParser.new
    for string in strings
      process("parsing #{string.inspect}") do
        parser.parse(string, root: root).should be_nil
      end
    end
  end
  
  def should_partly_parse(root, strings_and_expected)
    parser = CorrespondenceMarkupLanguageParser.new
    parser.consume_all_input = false
    for string_and_expected in strings_and_expected do
      string = string_and_expected[0]
      expected = string_and_expected[1]
      process("parsing #{string.inspect} and expecting #{expected.inspect}") do
        result = parser.parse(string, root: root)
        result.text_value.should == expected
      end
    end
  end
  
  it "parses number with one or more decimal digits only" do
    should_parse(:number, ["45", "5", "6677", "99999988"])
    should_not_parse(:number, ["", "-45", "6 7", "jim"])
    should_partly_parse(:number, [["45n", "45"], 
                                  ["89 234", "89"]])
  end
  
  it "parses item from [<number><whitespace><whatever>]" do
    should_parse(:item, ["[34 item text]", "[56 99]"])
    should_not_parse(:item, ["34 item text]", 
                             "[item text]", 
                             "[34 item", 
                             "[34 item]]", 
                             "[34 item] more", 
                             "[34]", 
                            ])
    should_partly_parse(:item, [["[56 99] after that", "[56 99]"]])
  end
  
  it "parses non_item anything not '['" do
    should_parse(:non_item, ["anything"])
    should_not_parse(:non_item, ["[", "anything ["])
    should_partly_parse(:non_item, [["anything[", "anything"]])
    should_partly_parse(:non_item, [[" [", " "]])
  end
  
  it "parses structure from text & items ..." do
    should_parse(:structure, ["", 
                              "[1 Hello]", 
                              "[1 Hello][2 world]", 
                              " [1 Hello]", 
                              "non-item text", 
                              "[1 Hello] [2 World].", 
                              "non-item [1 item 1] [2 item 2] the end"])
    should_not_parse(:structure, ["[", 
                                  "]", 
                                  "[]", 
                                  "1 Hello] [2 world", 
                                  "[1 Hello", 
                                  "[1 Hello]]", 
                                  "[1 Hello]  [2 world", 
                                  ])
  end
  
  it "parses structure group from from structure ..." do
    should_parse(:structure_group, ["", "[]", "[[1 x]]", 
                                    "[[1 Hello] [2 world]]", 
                                    "[[1 Hello] [2 world]][[1 Hola] [2 Mundo]]", 
                                    "[[1 Hello] [2 world]] [[1 Hola] [2 Mundo]]", 
                                    " [[1 Hello] [2 world]] [[1 Hola] [2 Mundo]] "
                                   ])
    should_not_parse(:structure_group, ["[", "[[]", "[[]][[", "[[]]]", "[[]]"])
                                        
  end
  
end
