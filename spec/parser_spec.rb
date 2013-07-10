require 'correspondence-markup'

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
  
  it "parses optional space" do
    should_parse(:s, ["", " ", "\r\n\t", "    \n\n"])
    should_not_parse(:s, ["x", "     .   \n"])
    should_partly_parse(:s, [["\n\n    x  \n", "\n\n    "], 
                             ["hello  ", ""]])
  end
  
  it "parses non-optional space" do
    should_parse(:S, [" ", "\r\n\t", "    \n\n"])
    should_not_parse(:S, ["", "x", "     .   \n"])
    should_partly_parse(:S, [["\n\n    x  \n", "\n\n    "], 
                             [" hello  ", " "]])
  end    
  
  it "parses structure class" do
    should_parse(:structure_class, ["english", "ruby", "us-english", "", "english2"])
    should_not_parse(:structure_class, ["55", "us english", "2english"])
  end
  
  it "parses item id with optional upper-case alphabetic and one or more decimal digits" do
    should_parse(:item_id, ["45", "5", "6677", "99999988", "A31", "AB31"])
    should_not_parse(:item_id, ["", "-45", "6 7", "jim", "A"])
    should_partly_parse(:item_id, [["45n", "45"], 
                                   ["89 234", "89"], 
                                   ["A31 [", "A31"]])
  end
  
  it "parses item ids separated by commas" do
    should_parse(:item_ids, ["45", "B9", "1,2", "B1,A3"])
    should_not_parse(:item_ids, ["", "1, 2"])
    should_partly_parse(:item_ids, [["1,2n", "1,2"]]) 
  end
  
  it "parses item from [<item id><whitespace><whatever>]" do
    should_parse(:item, ["[34 item text]", "[56 99]", "[A2 anything]", "[A2,4 with multiple ids]"])
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
    should_partly_parse(:non_item, [["anything[", "anything"], [" [", " "]])
  end
  
  it "parses backslash-quoted characters" do
    should_parse(:non_item, ["\\[ \\\\ \\]"])
  end
  
  it "parses item group" do
    should_parse(:item_group, ["[1 Hello] [2 world]", "", 
                               "A: [1 Hello] [2 world]"])
  end  
  
  it "parses structure from optional style + item groups ..." do
    should_parse(:structure, ["", "[]", 
                              "[[1 Hello]]", 
                              "english [A: [1 Hello]]", 
                              "[A: [1 Hello]][B: [1 world]]", 
                              "[A: [1 Hello]]", 
                              "[A: non-item text][B: [2 item]]", 
                              "[A: [1 Hello]][B[2 World].]", 
                              "[ non-item [1 item 1] [2 item 2] the end]"])
    should_not_parse(:structure, ["[", 
                                  "]", 
                                  "[[1 Hello] [2 world]", 
                                  "[[1 Hello]", 
                                  "[[1 Hello]]]", 
                                  "[1 Hello]  [2 world", 
                                  ])
  end
  
  it "parses structure group from from { structure } ..." do
    should_parse(:structure_group, ["", "{}", "{[[1 x]]}", "{[]}", 
                                    " {[A: [1 Hello]] [B: [1 world]]} {[A: [1 Hola]] [B: [2 Mundo]] }", 
                                    "{[A: [1 Hello]] [B: [1 world]]}{[A: [1 Hola]] [B: [2 Mundo]]}"
                                   ])
    should_not_parse(:structure_group, ["[", "{[]", "{[]}{[", "[[]]}", "{[[]]}"])
                                        
  end
  
  it "parses structure group description" do
    should_parse(:structure_group, ["#Description of this group\n{[[1 x]]}"])
    should_not_parse(:structure_group, ["Description of this group\n{[[1 x]]}", 
                                        "#Description of this group{[[1 x]]}"])
  end
  
  it "parses structure groups from ( structure ... ) ..." do
    should_parse(:structure_groups, ["()", "({[]})", 
                                     " ({[A: [1 Hello]] [B: [1 world]]} {[A: [1 Hola]] [B: [2 Mundo]] })" +
                                     " ({[A: [1 Goodbye]] [B: [1 friends]]} {[A: [1 Ciao]] [B: [2 amigos]] })"
                                    ])
    should_parse(:structure_groups, [%{
                                       (
                                        {
                                         [A: [1 hello] [2 world]]
                                        }
                                        {
                                         [A: [1 hola] [2 mundo]]
                                        }
                                       )
                                       (
                                        {
                                         [B: [1 One] [2 more]]
                                         [A: [1 item]]
                                        }
                                        {
                                         [B: [1 A singular] [2 additional]]
                                         [A: [1 thing]]
                                        }
                                       )
                                      }])
    should_parse(:structure_groups, [ %{
              ( {[[1 Hello] in between stuff [2 world]]}
                {[[1 Hola]  [2 mundo]]} )
              ( {[[3 3] [4 +] [5 4] [6 =] [7 7]]}
                {[[3 three] [4 and] [5 four] [6 makes] [7 seven]]} )
             }])
  end
  
end
