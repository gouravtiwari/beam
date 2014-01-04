# Beam
[![Gem Version](https://badge.fury.io/rb/beam.png)](http://badge.fury.io/rb/beam) [![Build Status](https://travis-ci.org/gouravtiwari/beam.png?branch=master)](https://travis-ci.org/gouravtiwari/beam) [![Coverage Status](https://coveralls.io/repos/gouravtiwari/beam/badge.png?branch=master)](https://coveralls.io/r/gouravtiwari/beam?branch=master)

A rubygem to simplifiy repetitive csv upload process for ActiveRecord models in rails applications. 
Supports bulk upload with [activerecord-import](http://rubygems.org/gems/activerecord-import)

## Usage

1. Add it the application's Gemfile:
    ```ruby
    gem 'beam'
    ```

    Run the generator

    ```ruby
    rails g beam:install
    ```

    This will create a config file for you to over-ride default options of upload process.

    ```ruby
    create  config/initializers/beam.rb
    ```
    
    Add [activerecord-import gem](http://rubygems.org/gems/activerecord-import) to the application's Gemfile:
    
    ```ruby
    gem 'activerecord-import', '0.4.1' # for rails-4.1 app
    gem 'activerecord-import', '0.4.0' # for rails-4.0 app
    gem 'activerecord-import', '0.3.1' # for rails-3.1+ app
    ```

2. Add it to the model you want to import csv file
    
    ```ruby
    extend Beam::Upload
    ```

3. Upload zipped csv file, e.g. users.csv.zip
  
    ```ruby
    Model.upload_file(file_name, file_path)
    
    # where users.csv has headers and rows, e.g.:
    # name,email
    # Test1,
    # Test2,test2@test.com
    # Test3,test3@test.com
    # Test4,test4@test.com
    ```

4. Only if you would like to use upload_controller_methods (to help you upload files zipped-csv files, as fake.csv.zip) include below routes in config/routes.rb (for fake_controller):
    ```ruby
    post "fake/upload", to: "fake#upload"
    get  "fake/error_file", to: "fake#error_file"
    ```
    include these methods in the controller:
    ```ruby
    class FakeController < ApplicationController
      include Beam::UploadControllerMethods
    end
    ...
    ...
    ```
    and add view snippet to app/views/fake/upload_form.html.erb
    ```ruby
    <%= form_tag users_upload_path, :multipart => true do %>
    <%= file_field_tag 'upload[upload_file]'%>
      <%= submit_tag "Upload" %>
    <% end %>
    ```

5. Get the output as:
  
    ```ruby
    # response hash, e.g. 
      {:errors=>1, :status=>200, :total_rows=>4, :error_rows=>[["Test1", nil, "is invalid"]]}
    # error file, e.g.
    # for users.csv file, it creates errors_users.csv at the same path specified in Beam.config (Rails.root+'/tmp')
    # see records being saved in batch(by default) of 1_000 with activerecord-import gem
    ```

## Configuration options:

Default configurations, to change these, update config/initializers/beam.rb:
Beam.config[:error_file_needed] = true
Beam.config[:batch_process]     = true
Beam.config[:batch_size]        = 1_000
Beam.config[:zipped]            = true
Beam.config[:data_upload_path]  = "#{Rails.root}/tmp"


## TO DO

SideKiq & DelayedJob options

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
