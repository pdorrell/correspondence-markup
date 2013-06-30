
module CorrespondenceMarkup
  module TestMethods
    def process(description)
      begin
        # puts "process #{description} ..."
        yield
      rescue Exception => ex
        raise Exception, "ERROR #{description}: #{ex.message}"
      end
    end
  end
end

def normalise_html(html)
  html.gsub(/\s+/, " ")
end

RSpec::Matchers.define :match_as_html do |expected|
  match do |actual|
    normalise_html(actual) == normalise_html(expected)
  end
  failure_message_for_should do |actual|
    "   actual: #{normalise_html(actual).inspect}\n expected: #{normalise_html(expected).inspect}"
  end
end

RSpec.configure do |c|
  c.include CorrespondenceMarkup::TestMethods
end
