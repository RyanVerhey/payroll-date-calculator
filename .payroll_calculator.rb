class PayrollCalculator
  @holidays = []

  class << self
    attr_accessor :holidays
  end

  def self.calculate(start_date, pay_interval, payday, holiday_filename, months = 12)
    date_counter = start_date
    date_counter = date_counter.next_wday(payday) if date_counter.wday != payday
    date_arr = []
    if holiday_filename
      self.import_holidays(holiday_filename)
    end
    until date_counter > start_date >> months
      if self.invalid_payday?(date_counter)
        if pay_interval == "daily"
          date_counter = date_counter.next_day until !self.invalid_payday?(date_counter)
        else
          date_counter = date_counter.prev_day until !self.invalid_payday?(date_counter)
        end
      else
        date_arr << date_counter.strftime('%m/%d/%Y')
        case pay_interval
        when "daily"
          date_counter = date_counter.next_day
          payday = date_counter.wday
        when "weekly" then date_counter = date_counter.next_day(7)
        when "bi-weekly" then date_counter = date_counter.next_day(14)
        when "monthly" then date_counter >> 1
        end
        if date_counter.wday != payday && !self.invalid_payday?(date_counter)
          date_counter = date_counter.next_wday(payday)
        end
      end
    end
    date_arr
  end

  def self.invalid_payday?(date)
    date.saturday? || date.sunday? || self.holidays.include?(date)
  end

  def self.import_holidays(file_path)
    File.open(file_path, "r") do |file|
      file.each_line do |line|
        begin
          self.holidays << Date.strptime(line.strip, '%m/%d/%Y')
        rescue
          puts "There was an invalid holiday date: #{line.strip}. It was ignored."
        end
      end
    end
  end
end
