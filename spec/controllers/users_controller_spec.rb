require 'spec_helper'
require_relative Beam.lib+'/beam/upload_controller_methods'
class UsersController < ApplicationController
  include Beam::UploadControllerMethods
end

# class FakeTest
# end

describe UsersController do
  before(:each) do
    Rails.application.routes.draw do
      post "users/upload", to: "users#upload"
      get  "users/error_file", to: "users#error_file"
    end
  end

  after(:each) do
    Rails.application.reload_routes!
  end

  it 'should send error file' do
    expect(@controller).to receive(:send_file).with("#{Beam.config[:data_upload_path]}/errors_users.csv")
    expect(@controller).to receive(:render)

    get :error_file

    response.should be_success
  end

  context 'upload' do
    before(:each) do
      @request.env["HTTP_ACCEPT"] = "application/json"
      @request.env["CONTENT_TYPE"] = "application/json"
    end

    it 'should return error when the file is not detected' do
      expect(@controller).to receive(:params).and_return({ upload: {} })

      post :upload, {upload: {}}

      response.header['Content-Type'].should include('application/json')
      response.body.should  == {error_msg: "No file detected, please upload a file", 
                                  message: "No file detected, please upload a file", 
                                  status: "failure",
                                  status_code: 500
                                }.to_json
    end

    it 'should upload file and return error when the file is not a zipped csv file' do
      expect(@controller).to receive(:params).and_return({ upload: {upload_file: file=double(content_type: 'text/xlsx')} })

      post :upload, {upload: {upload_file: "some mock file"}}

      response.header['Content-Type'].should include('application/json')
      response.body.should  == {error_msg: "Only zipped csv files are allowed", 
                                  message: "Only zipped csv files are allowed", 
                                  status: "failure",
                                  status_code: 500
                                }.to_json
    end

    it 'should upload file and return failure when file upload process gives 500' do
      expect(@controller).to receive(:params).and_return({ upload: {upload_file: file=double(content_type: 'application/zip', original_filename: 'test.zip')} })
      expect(@controller).to receive(:upload_file).with(file).and_return(upload_response = {status: 500})
      expect(@controller).to receive(:zip_file?).with(file).and_return(true)
      post :upload, {upload: {upload_file: "some mock file"}}

      response.header['Content-Type'].should include('application/json')
      response.body.should  == {
                                  num_errors: 1,
                                  controller_name: 'users',
                                  error_msg: "Please check the format of zipped file", 
                                  message: "Please check the format of zipped file", 
                                  status: "failure",
                                  status_code: 500
                                }.to_json
    end

    it 'should upload file and return success when uploaded through queue' do
      pending "DelayedJob & SideKiq placehoder"
    end

    it 'should upload file and return success when uploaded with zero error' do
      tempfile = fixture_file_upload(Beam.spec + '/fixturesspec/users.csv.zip', 'application/zip')
      expect(@controller).to receive(:params).and_return({ upload: {
                                                              upload_file: file=double(content_type: 'application/zip', 
                                                              tempfile: tempfile,
                                                              original_filename: 'users.csv.zip')
                                                            } 
                                                          })
      expect(User).to receive(:upload_file).with('users.csv.zip', Beam.tmp).and_return(upload_response = {status: 200, errors: 0})
      expect(@controller).to receive(:zip_file?).with(file).and_return(true)

      post :upload, {upload: {upload_file: "some mock file"}}

      response.header['Content-Type'].should include('application/json')
      response.body.should  == {
                                  num_errors: 0,
                                  controller_name: 'users',
                                  success_msg: "File uploaded successfully", 
                                  message: "File uploaded successfully", 
                                  status: "success",
                                  status_code: 200
                                }.to_json

    end

    it 'should upload file and return success when uploaded with > 0 error' do
      tempfile = fixture_file_upload(Beam.spec + '/fixturesspec/users.csv.zip', 'application/zip')
      expect(@controller).to receive(:params).and_return({ upload: {
                                                              upload_file: file=double(content_type: 'application/zip', 
                                                              tempfile: tempfile,
                                                              original_filename: 'users.csv.zip')
                                                            } 
                                                          })
      expect(User).to receive(:upload_file).with('users.csv.zip', Beam.tmp).and_return(upload_response = {status: 200, errors: 1})
      expect(@controller).to receive(:zip_file?).with(file).and_return(true)
      post :upload, {upload: {upload_file: "some mock file"}}

      response.header['Content-Type'].should include('application/json')
      response.body.should  == {
                                  num_errors: 1,
                                  controller_name: 'users',
                                  error_msg: msg = "There are 1 row(s) with errors while uploading config file." + 
                                            " Please check whether you have selected correct module or you have valid data in the file.", 
                                  message: msg, 
                                  status: "failure",
                                  status_code: 500
                                }.to_json

    end
  end
end
