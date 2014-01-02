module Beam
  module UploadControllerMethods
    attr_accessor :model, :upload_method  

    def upload
      upload_status = file_upload_status(params)
      upload_status.merge!(additional_params_on_success) if upload_status[:success_msg]

      respond_to do |format|
        format.json { render json: upload_status }
      end
    end

    def error_file
      send_file "#{Beam.config[:data_upload_path]}/#{self.controller_name.downcase}_errors.csv"
    end
    
    def self.included(base)
      private

      # hook for post successful upload, in case additional parameters need to be send
      def additional_params_on_success
        {}
      end

      def zip_file?(upload_file)
        ["application/zip", "application/x-zip-compressed", "application/octet-stream"].include?(upload_file.content_type)  && upload_file.original_filename.include?(".zip")
      end

      def file_upload_status(params)
        file_obj = params[:upload] ? params[:upload][:upload_file] : params[:files][0]

        status = file_obj ? file_status(file_obj) : not_file_status
        status[:message] = status[:num_errors] && status[:num_errors].zero? ? status[:success_msg] : status[:error_msg]
        status[:status] = status[:message] == status[:success_msg] ? "success" : "failure"
        status[:status_code] = status[:message] == status[:success_msg] ? 200 : 500
        status
      end

      def file_status(file)
        zip_file?(file) ? csv_file_status(file) : not_csv_file_status
      end

      def not_file_status
        {error_msg: "No file detected, please upload a file"}
      end

      def csv_file_status(file)
        response = upload_file(file)
        upload_status_by_response(response)
      end

      def upload_file(file)
        @model ||= controller_name.classify.constantize
        @upload_method ? 
          @model.upload_file(file, Beam.config[:data_upload_path], @upload_method) :
          @model.upload_file(file, Beam.config[:data_upload_path])
      end

      def not_csv_file_status
        {error_msg: "Only zipped csv files are allowed"}
      end

      def upload_status_by_response(response)
        if response[:status] == 500
          failure_status
        else
        response[:errors].zero? ? 
          upload_without_queue_success_status :
          upload_without_queue_failure_status(response[:errors])
        end
      end

      def failure_status
        {num_errors: 1, controller_name: self.controller_name, error_msg: "Please check the format of zipped file"}
      end

      def upload_through_queue_status(errors)
        { 
          num_errors:      nil,
          controller_name: self.controller_name,
          success_msg:     "In Progress"
        }   
      end

      def upload_without_queue_success_status
        { 
          num_errors:      0,
          controller_name: self.controller_name,
          success_msg:     "File uploaded successfully"
        }
      end

      def upload_without_queue_failure_status(errors)
        { 
          num_errors:      errors,
          controller_name: self.controller_name,
          error_msg:       "There are #{errors} row(s) with errors while uploading config file." + 
                            " Please check whether you have selected correct module or you have valid data in the file."
        }
      end
      
    end
   
  end
end
