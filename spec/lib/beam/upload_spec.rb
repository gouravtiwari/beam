require 'active_record'
require 'spec_helper'
require_relative '../../../lib/beam/upload'

class User < ActiveRecord::Base
  extend Beam::Upload
end

describe Beam::Upload do
  context "zipped file" do
    it 'should not upload anything and return error, when file is not present' do
      User.upload_file("file_not_present.zip", "unknown_path").should == {:errors=>1, 
                                                                          :status=>500, 
                                                                          :total_rows=>0, 
                                                                          :error_rows=>["Please upload the right template and verify data before upload"]
                                                                          }
    end

    it 'should upload zipped csv file when file is present'
  end

  context "CSV file" do
    before(:each) do
      Beam.config[:zipped] = false
    end
    after(:each) do
      Beam.config[:zipped] = true
    end
    it 'should not upload anything and return error, when file is not present' do
      User.upload_file("file_not_present.csv", "unknown_path").should == {:errors=>1, 
                                                                          :status=>500, 
                                                                          :total_rows=>0, 
                                                                          :error_rows=>["Please upload the right template and verify data before upload"]
                                                                          }
    end

    it 'should upload zipped csv file when file is present'
  end

  context "validation" do
    it 'should upload file and return validation error'
    it 'should upload file and return validation error CSV file'
    it 'should upload file and return success'
  end

  context "batch upload" do
    it 'should upload file and create records in batches'
    it 'should upload file and create records one-by-one'
  end
end