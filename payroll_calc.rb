require 'date'

WEEK_DAYS = { "monday" => 1,
              "tuesday" => 2,
              "wednesday" => 3,
              "thursday" => 4,
              "friday" => 5 }

class Date
  def this_week
    self - self.wday
  end

  def next_week
    self + (7 - self.wday)
  end

  def next_wday(n)
    n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
  end

  def last_week
    self.this_week - 7
  end

  def last_wday(n)
    n < self.wday ? self - (self.wday - n) : self.last_week.next_day(n)
  end
end



class PayrollController
  def initialize(start_date = nil, pay_interval = nil, payday = nil, holiday_filename = nil)
    @start_date = start_date
    @pay_interval = pay_interval
    @payday = payday
    @holiday_filename = holiday_filename
  end

  def run
    puts "Welcome to Ryan's Payroll Calculator!"
    puts "You can type \"help\" at any time if you need it."
    puts ""
    get_start_date
    puts ""
    get_pay_interval
    puts ""
    @pay_interval == "daily" ? @payday = @start_date.wday : get_payday
    puts ""
    get_holiday_file
    puts ""
    date_arr = PayrollCalculator.calculate(@start_date, @pay_interval, @payday, @holiday_filename)
    print_list_of_dates(date_arr)
  end

  private

  def get_start_date(input_date = nil)
    puts "Is there a specific start date you want to start from? Please use the MM/DD/YYYY format."
    puts "If not, just press Enter and the start date will be today."
    input_date ||= gets.chomp!
    if input_date =~ /\A\d{2}\/\d{2}\/\d{4}\z/
      begin
        @start_date = Date.strptime(input_date, '%m/%d/%Y')
      rescue
        invalid_date_reset
      end
    elsif input_date == ""
      @start_date = Date.today
    elsif input_date.downcase == "help"
      help_command(__method__)
    else
      invalid_date_reset
    end
    @start_date
  end

  def invalid_date_reset
    puts ""
    puts "I'm sorry, that is not a valid date. Please try again."
    puts ""
    get_start_date
  end

  def get_pay_interval(input_interval = nil)
    puts "Is there a specific pay interval you would like?"
    puts "The accepted intervals are daily, weekly, bi-weekly, and monthly."
    puts "If you don't have a specific interval, just press enter and it will be set to bi-weekly."
    input_interval ||= gets.chomp!
    input_interval.downcase!
    if ["daily", "weekly", "bi-weekly", "monthly"].include? input_interval
      @pay_interval = input_interval
    elsif input_interval == ""
      @pay_interval = "bi-weekly"
    elsif input_interval == "help"
      help_command(__method__)
    else
      puts ""
      puts "I'm sorry, that was not a recognized pay interval. Please try again"
      puts ""
      get_pay_interval
    end
    @pay_interval
  end

  def get_payday(input_day = nil)
    puts "Is there a specific day of the week you want your employees to be paid on?"
    puts "If not, then just press Enter and it will be set to Friday."
    puts "NOTE: Payday CANNOT be on a Saturday or Sunday."
    input_day ||= gets.chomp!
    input_day.downcase!
    if WEEK_DAYS.keys.include? input_day
      @payday = WEEK_DAYS[input_day]
    elsif input_day == ""
      @payday = 5
    elsif input_day == "help"
      help_command(__method__)
    else
      puts ""
      puts "I'm sorry, that was not a valid day of the week. Please try again."
      puts ""
      get_payday
    end
  end

  def get_holiday_file(input = nil)
    puts "Would you like to pass in a .txt file with holidays? If you do, and a"
    puts "payday lands on that holiday, the payday for that interval will be moved"
    puts "to the first valid payday before the holiday."
    puts "If yes, type 'yes'."
    puts "If you don't want to pass in a file, just press Enter."
    input ||= gets.chomp!
    if input.downcase == "help"
      help_command(__method__)
    elsif input == ""
      #nothing
    elsif input.downcase == "yes"
      puts "Each date has to be on a new line."
      puts "If you want to pass in a file, put it in the following directory:"
      puts "  #{File.expand_path(File.dirname(__FILE__))}."
      puts "Then, type in the filename like this: filename.txt"
      puts "The dates must be in the following format: MM/DD/YYYY."
      file_input = gets.chomp!
      if File.extname(file_input) == ".txt"
        if File.file?(file_input)
          @holiday_filename = file_input
        else
          puts ""
          puts "I'm sorry, the file doesn't exist. Please move it into the following directory:"
          puts "  #{File.expand_path(File.dirname(__FILE__))}"
          puts ""
          get_holiday_file
        end
      else
        puts ""
        puts "I'm sorry, that file is not a recognized format. Please try again."
        puts ""
        get_holiday_file
      end
    else
      puts ""
      puts "I'm sorry, your input was not recognized. Please try again."
      puts ""
      get_holiday_file
    end
    @holiday_filename
  end

  def print_list_of_dates(date_arr)
    puts "OK, here is the list of payroll dates:"
    puts ""
    date_arr.each { |date| puts date; puts "" }
  end

  def help_command(sender_method)
    system('clear')
    case sender_method
    when :get_start_date
      puts ""
      puts "Please input the date you would like to start the payroll calculations from"
      puts "using the format MM/DD/YYYY."
      puts "For example, if you want the calculations starting from next Monday, just type"
      puts "in #{Date.today.next_wday(1).strftime('%m/%d/%Y')}."
      puts ""
    when :get_pay_interval
      puts ""
      puts "Please input how often you would like your employees to be paid. The accepted"
      puts "intervals are daily, weekly, bi-weekly, and monthly."
      puts "So, if you would like your employees to be paid every week, type in \"weekly\""
      puts ""
    when :get_payday
      puts ""
      puts "Please type in the day of the week you would like your employees to be paid on."
      puts "The accepted days are Monday, Tuesday, Wednesday, Thursday, and Friday. Weekends"
      puts "(Saturday and Sunday) are not accepted."
      puts ""
    end
    method(sender_method).call
  end
end



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

controller = PayrollController.new
controller.run

# PayrollCalculator.import_holidays("dates.txt")
