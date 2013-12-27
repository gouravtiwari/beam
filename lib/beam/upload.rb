require 'csv'

module Beam
    # error_file_needed:true if you need error file to be created, default is true
    # batch_process:    default is true, set to false if you do not use activerecord-import 
    #                   for batch processing
    # batch_size:       default is 1_000, change it to batch of records you want to upload
    # zipped:           set it to true if uploaded file is zipped
    @config = {
      error_file_needed:  true,
      batch_process:      true,
      batch_size:         1_000,
      zipped:             true
    }

    @valid_config_keys = @config.keys

    # Configure through hash
    def self.configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    def self.config
      configure(@config)
    end

  module Upload
    def upload_config
      @error_file_needed  = Beam.config[:error_file_needed]
      @batch_process      = Beam.config[:batch_process]
      @batch_size         = Beam.config[:batch_size]
      @zipped             = Beam.config[:zipped]
    end

    # params:
    #       file_name:        zip file name, e.g. users.csv.zip
    #       file_path:        path/to/zip-file, e.g. Rails.root/tmp
    #       callback_method:  method which does the job to load records, default is parse method
    def upload_file(file_name, file_path, callback_method='parse')
      status = {}
      upload_config
      @file_name          = file_name
      @file_path          = file_path      
      @original_zip_file  = "#{@file_path}/#{@file_name}"
      @csv_file_name      = @file_name.gsub(/\.zip/,'')

      begin
        if @zipped
          delete_csv_if_present
          unzip_file
        end
        
        status = self.send(callback_method)
      rescue Exception =>  e
        error_in_upload([[invalid_file_message]]) if @error_file_needed
        Rails.logger.error e.formatted_exception("Uploading file #{@file_name} failed!")
        status = { errors: 1, status: 500}
      end
      status
    end

    # unzips a zipped-csv-file in a given directory
    def unzip_file
      `unzip #{@file_path}/#{@file_name} -d #{@file_path}`
    end

    # deletes csv file upfront before we unzip the file
    def delete_csv_if_present
      File.delete "#{@file_path}/#{@csv_file_name}" if File.exists? "#{@file_path}/#{@csv_file_name}"
    end

    # Creates error file with error rows, e.g.
    # for users.csv file, it creates errors_users.csv
    def error_in_upload(rows)
      csv_file_path = "#{@file_path}/errors_#{@csv_file_name}"
      begin
        CSV.open(csv_file_path, "wb") do |csv|
          rows.each do |row|
            csv << row
          end
        end
      rescue Exception => e
        Rails.logger.error e.formatted_exception("Building error file for #{@file_name} failed!")
      end
    end

    # Validates each record and returns error count if record is invalid
    def validate_record(errors_count, row_hash, index)
      record = new(row_hash)
      unless record.valid?
        errors_count += 1
        [nil, errors_count, log_and_return_validation_error(record, row_hash, index)]
      else
        [record, errors_count, nil]
      end
    end

    # parses the csv file, creates record for the model and returns response hash,e.g.
    # \{:errors=>1, :status=>200, :total_rows=>4, :error_rows=>[["Test1", nil, "is invalid"]]\}
    # also, it creates error file to consume
    def parse
      response  = { errors: 0, status: 200, total_rows: 0, error_rows: []}
      index = 0
      batch = []

      begin
        CSV.foreach("#{@file_path}/#{@csv_file_name}", :encoding => 'iso-8859-1:UTF-8', headers: true) do |row|
          index += 1
          row_hash = row.to_hash
          response[:total_rows] += 1
          begin
            record, response[:errors], error_row = validate_record(response[:errors], row_hash, index)
            response[:error_rows] << error_row if error_row
              
            if @batch_process
              batch = add_to_batch(batch, record)
            else
              record.save!
            end
          rescue Exception => e
            response[:errors] +=1
            response[:error_rows] << log_and_return_error(row_hash, e, index)
          end
        end
        import_from_batch(batch)
      rescue Exception => e
        response[:errors] = 1
        log_and_return_error({}, e, '')
      end

      if response[:error_rows].blank?
        post_parse_success_calls 
      elsif @error_file_needed
        error_in_upload(response[:error_rows])
      end

      response
    end

    def add_to_batch(batch, record)
      batch << record if record
      if batch.size >= @batch_size
        import_from_batch(batch, true)
        batch = []
      end
      batch
    end

    def import_from_batch(batch)
      import(batch, :validate => false) if @batch_process
    end

    def log_and_return_validation_error(record, row_hash, index)
      error_msg = record.errors.messages.values.join(', ')
      Rails.logger.error("Error on #{index}: \n #{row_hash.values + [error_msg]}")
      row_hash.values + [error_msg]
    end

    def log_and_return_error(row_hash, e, index)
      Rails.logger.error e.formatted_exception("Error on #{index}: \n #{row_hash.values}")
      row_hash.values + [invalid_file_message]
    end

    def invalid_file_message
      "Please upload the right template and verify data before upload"
    end

    def post_parse_success_calls
      # abstract method
    end
  end
end
