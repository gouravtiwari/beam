require 'csv'
module Beam
  module Upload
    # params:
    #       file_name:        zip file name, e.g. users.csv.zip
    #       file_path:        path/to/zip-file, e.g. Rails.root/tmp
    #       error_file_needed:true if you need error file to be created, default is true
    #       callback_method:  method which does the job to load records, default is parse method
    def upload_file(file_name, file_path, error_file_needed=true, callback_method = "parse")
      status = {}
      @file_name = file_name
      @file_path = file_path
      @error_file_needed  = error_file_needed
      @original_zip_file  = "#{@file_path}/#{@file_name}"
      @csv_file_name      = @file_name.gsub(/\.zip/,'')

      begin
        delete_csv_if_present
        `unzip #{@file_path}/#{@file_name} -d #{@file_path}`

        status = self.send(callback_method)
      rescue Exception =>  e
        error_in_upload([[invalid_file_message]]) if @error_file_needed
        Rails.logger.error e.formatted_exception("Uploading file #{@file_name} failed!")
        status = { errors: 1, status: 500}
      end
      status
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
    # {:errors=>1, :status=>200, :total_rows=>4, :error_rows=>[["Test1", nil, "is invalid"]]}
    # also, it creates error file to consume
    def parse
      response  = { errors: 0, status: 200, total_rows: 0, error_rows: []}
      index = 0

      begin
        CSV.foreach("#{@file_path}/#{@csv_file_name}", :encoding => 'iso-8859-1:UTF-8', headers: true) do |row|
          index += 1
          row_hash = row.to_hash
          response[:total_rows] += 1
          begin
            record, response[:errors], error_row = validate_record(response[:errors], row_hash, index)
            if error_row
              response[:error_rows] << error_row
            else
              record.save!
            end
          rescue Exception => e
            response[:errors] +=1
            response[:error_rows] << log_and_return_error(row_hash, e, index)
          end
        end
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
