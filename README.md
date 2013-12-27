# Beam

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

4. Get the output as:
  
    ```ruby
    # response hash, e.g. 
      {:errors=>1, :status=>200, :total_rows=>4, :error_rows=>[["Test1", nil, "is invalid"]]}
    # error file, e.g.
      for users.csv file, it creates errors_users.csv at the same path
    # see records being saved in batch(by default) of 1_000 with activerecord-import gem
    ```

See beam/upload.rb for more details

## TO DO

SPECS!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
