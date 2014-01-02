require 'active_record'
require 'spec_helper'
require_relative Beam.lib+'/beam/upload'

describe Beam::Upload do
  context "zipped file" do
    it 'should not upload anything and return error, when file is not present' do
      User.upload_file("file_not_present.zip", "unknown_path").should == {:errors=>1, 
                                                                          :status=>500, 
                                                                          :total_rows=>0, 
                                                                          :error_rows=>["Please upload the right template and verify data before upload"]
                                                                          }
    end

    it 'should upload zipped csv file when file is present' do
      `cp -f #{Beam.spec}/fixturesspec/users.csv.zip #{Beam.tmp}`
      response = User.upload_file("users.csv.zip", Beam.tmp)
      response[:status].should == 200
    end
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

    it 'should upload csv file when file is present' do
      `cp -f #{Beam.spec}/fixturesspec/users.csv #{Beam.tmp}`
      response = User.upload_file("users.csv", Beam.tmp)
      response[:status].should == 200
    end
  end

  context "validation" do
    it 'should upload file and return validation error' do
      `cp -f #{Beam.spec}/fixturesspec/users_with_errors.csv.zip #{Beam.tmp}`
      response = User.upload_file("users_with_errors.csv.zip", Beam.tmp)
      response[:errors].should == 1
      response[:error_rows].should == [["Test1", nil, "can't be blank"]]
    end

    it 'should upload file and return validation error CSV file' do
      `cp -f #{Beam.spec}/fixturesspec/users_with_errors.csv.zip #{Beam.tmp}`
      User.upload_file("users_with_errors.csv.zip", Beam.tmp)

      File.exists?(Beam.tmp+"/errors_users_with_errors.csv").should be_true
    end

    it 'should upload file and return success response' do
      `cp -f #{Beam.spec}/fixturesspec/users.csv.zip #{Beam.tmp}`
      response = User.upload_file("users.csv.zip", Beam.tmp)
      response[:status].should == 200
      response[:errors].should == 0
      response[:total_rows].should == 4
    end
  end
end