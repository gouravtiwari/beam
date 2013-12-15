# Beam

A rubygem to simplifiy repetitive csv upload process for ActiveRecord models

## Usage

1. Add it to the model you want to import csv file
    
    ```ruby
    extend Beam::Upload
    ```

2. Upload zipped csv file, e.g. users.csv.zip
  
    ```ruby
    Model.upload_file(file_name, file_path)
    
    # where users.csv has headers and rows, e.g.:
    # name,email
    # Test1,
    # Test2,test2@test.com
    # Test3,test3@test.com
    # Test4,test4@test.com
    ```

3. Get the output as:
  
    ```ruby
    # response hash, e.g. 
      {:errors=>1, :status=>200, :total_rows=>4, :error_rows=>[["Test1", nil, "is invalid"]]}
    # error file, e.g.
      for users.csv file, it creates errors_users.csv at the same path
    ```

See beam/upload.rb for more details

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
