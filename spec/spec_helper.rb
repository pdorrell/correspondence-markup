
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
  

RSpec.configure do |c|
  c.include CorrespondenceMarkup::TestMethods
end
