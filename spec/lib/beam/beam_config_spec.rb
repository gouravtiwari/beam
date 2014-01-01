require 'spec_helper'
require_relative '../../../lib/beam/upload'

describe "Beam Configuration" do
  {
    error_file_needed:  true,
    batch_process:      true,
    batch_size:         1_000,
    zipped:             true
  }.each do |configuration, option|
    it "should set default configuration for #{configuration}" do
      Beam.config[configuration].should == option
    end
  end
end