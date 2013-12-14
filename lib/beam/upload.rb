require 'csv'
require 'zip'
module Beam
  module Upload
    def upload_file(file_name, file_path, callback_method = "parse")
      status = {}
      original_zip_file = "#{file_path}/#{file_name}"
      begin
        unzipped_file_name = file_name.gsub(/\.zip/,'')
        unzipped_file_path = "#{file_path}/#{unzipped_file_name}"
        if File.exists? unzipped_file_path
          File.delete unzipped_file_path
        end
        `unzip #{file_path}/#{file_name} -d #{file_path}`
        `cat #{file_path}/#{unzipped_file_name}`  
        status = self.send(callback_method, unzipped_file_name, unzipped_file_path)
      end
      status
    end

    def validate_data(errors_count, row_hash, index)
      data = new(row_hash)
      unless data.valid?
        errors_count += 1
        [nil, errors_count, log_and_return_validation_error(data, row_hash, index)]
      else
        [data, errors_count, nil]
      end
    end

    def parse(file_name, file_path)
      response  = { errors: 0, status: 200, total_rows: 0}
      error_rows= []
      index = 0

      begin
        CSV.foreach(file_path, :encoding => 'iso-8859-1:UTF-8', headers: true) do |row|
          index += 1
          row_hash = row.to_hash
          response[:total_rows] += 1
          begin
            data, response[:errors], error_row = validate_data(response[:errors], row_hash, index)
            error_rows << error_row if error_row

            data.save!
          rescue Exception => e
            response[:errors] +=1
            error_rows << log_and_return_error(row_hash, e, index)
          end
        end
      rescue Exception => e
        response[:errors] = 1
        log_and_return_error({}, e, '')
      end

      response
    end

    def log_and_return_validation_error(data, row_hash, index)
      error_msg = data.errors.messages.values.join(', ')
      Rails.logger.error("Error on #{index}: \n #{row_hash.values + [error_msg]}")
      row_hash.values + [error_msg]
    end

    def log_and_return_error(row_hash, e, index)
      Rails.logger.error("Error on #{index}: \n #{row_hash.values} \n#{e.backtrace}")
      row_hash.values + [invalid_file_message]
    end

    def invalid_file_message
      "Please upload the right template and verify data before upload"
    end
  end
end
