require 'active_record'
require 'spec_helper'
require_relative '../../../lib/beam/upload'

class User < ActiveRecord::Base
  extend Beam::Upload
end

describe Beam::Upload do
  it 'should upload a file and return error, when file is not present' do
    User.upload_file("file_not_present.zip", "unknown_path").should == {:errors=>1, 
                                                                        :status=>500, 
                                                                        :total_rows=>0, 
                                                                        :error_rows=>["Please upload the right template and verify data before upload"]
                                                                        }
  end
end