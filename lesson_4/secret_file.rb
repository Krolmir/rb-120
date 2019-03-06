class SecretFile
  attr_reader :data, :tracker

  def initialize(secret_data, tracker)
    @tracker = tracker
    @data = secret_data
  end
  
  def data
    tracker.create_log_entry
    @data
  end
end

class SecurityLogger
  def create_log_entry
    # ...........    
  end
end


my_file = SecretFile.new("secret_data", SecurityLogger.new)