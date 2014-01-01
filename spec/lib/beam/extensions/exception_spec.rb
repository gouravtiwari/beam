require 'spec_helper'
require_relative '../../../../lib/beam/extensions/exception'

describe Exception do
  it "raises exception with formatting" do
    begin
      1/0
    rescue ZeroDivisionError => e
      e.formatted_exception("Testing Exceptions").should include("  An error occurred while Testing Exceptions:\n"+
                                                                 "  Type: ZeroDivisionError\n"+
                                                                 "  Message:  divided by 0\n"+
                                                                 "  Backtrace:\n")
    end
  end
end