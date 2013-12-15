class Exception
  def formatted_exception(error_message)
    <<-ERROR
      An error occurred while #{error_message}:
      Type: #{self.class.name}
      Message:  #{self.message}
      Backtrace:\n#{self.backtrace.join("\n")}
    ERROR
  end
end
