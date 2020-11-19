require_relative './database_connection'

class Counter
  attr_reader :time
  def count
    result = DatabaseConnection.query("SELECT * FROM counter WHERE id=1;")
    result[0]['count'].to_i
  end

  def increment
    read_count = count
    result = DatabaseConnection.query("UPDATE counter SET count = '#{read_count + 1}' WHERE id=1;")
    set_time
  end

  def decrement
    read_count = count
    set_time
    result = DatabaseConnection.query("UPDATE counter SET count = '#{read_count - 1}' WHERE id=1;")
  end

  def self.instance
    @counter ||= Counter.new
  end

  # private

  def set_time
    @time = Time.new.strftime("%k:%M:%S")
  end
end
