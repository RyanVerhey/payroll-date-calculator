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
  def initialize(start_date = nil, pay_interval = nil, payday = nil)
    @start_date = start_date
    @pay_interval = pay_interval
    @payday = payday
  end

  def run
    puts "Welcome to Ryan's Payroll Calculator!"
    puts ""
    get_start_date
    puts ""
    get_pay_interval
    puts ""
    if @pay_interval != "daily"
      get_payday
    else
      @payday = @start_date.wday
    end
    puts ""
    print_list_of_dates(PayrollCalculator.calculate(@start_date, @pay_interval, @payday))
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
    else
      puts "I'm sorry, that was not a recognized pay interval. Please try again"
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
    else
      puts "I'm sorry, that was not a valid day of the week. Please try again."
      get_payday
    end
  end

  def print_list_of_dates(date_arr)
    puts "OK, here is the list of payroll dates:"
    puts ""
    date_arr.each { |date| puts date; puts "" }
  end
end

class PayrollCalculator
  @@holidays = []

  def self.calculate(start_date, pay_interval, payday, months = 12)
    date_counter = start_date
    date_counter = date_counter.next_wday(payday) if date_counter.wday != payday
    date_arr = []
    until date_counter > start_date >> months
      date_arr << date_counter.strftime('%m/%d/%Y')
      case pay_interval
      when "daily" then date_counter = date_counter.next_day(1)
      when "weekly" then date_counter = date_counter.next_day(7)
      when "bi-weekly" then date_counter = date_counter.next_day(14)
      when "monthly" then date_counter >> 1
      end
    end
    date_arr
  end
end

controller = PayrollController.new
controller.run
