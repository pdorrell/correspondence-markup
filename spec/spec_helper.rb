
module CorrespondenceMarkup
  module TestMethods

    def input_file_contents(base_filename)
      output_filename = File.join(File.dirname(__FILE__), "input", base_filename)
      File.read(output_filename)
    end

    def output_file_contents(base_filename)
      output_filename = File.join(File.dirname(__FILE__), "output", base_filename)
      File.read(output_filename)
    end

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
