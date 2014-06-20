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
    load_settings_prompt
    date_arr = PayrollCalculator.calculate(@start_date, @pay_interval, @payday, @holiday_filename)
    print_list_of_dates(date_arr)
    save_settings
  end

  private

  def load_settings_prompt(settings_input = nil)
    if File.file?(".settings")
      puts "You have run this script before."
      puts "Would you like to run this script again with the same settings?"
      puts "Typing 'yes' will run the script with the inputs you used before,"
      puts "and typing 'no' or just pressing Enter will let you run this script normally."
      settings_input ||= gets.downcase.chomp!
      case settings_input
      when "yes" then load_settings
      when ""    then prompt_for_input
      when "no"  then prompt_for_input
      else
        puts ""
        puts "I'm sorry, that's not a recognized input. Please try again."
        puts ""
        load_settings_prompt
      end
    else
      prompt_for_input
    end
  end

  def prompt_for_input
    get_start_date
    puts ""
    get_pay_interval
    puts ""
    @pay_interval == "daily" ? @payday = @start_date.wday : get_payday
    puts ""
    get_holiday_file
    puts ""
  end

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

  def get_holiday_file(input = nil, file_input = nil)
    puts "Would you like to pass in a .txt file with holidays? If you do, and a"
    puts "payday lands on that holiday, the payday for that interval will be moved"
    puts "to the first valid payday before the holiday."
    puts "If yes, type 'yes'."
    puts "If you don't want to pass in a file, just press Enter."
    input ||= gets.chomp!
    case input.downcase
    when "help"
      help_command(__method__)
    when ""
      #nothing
    when "yes"
      puts "Each date has to be on a new line."
      puts "If you want to pass in a file, put it in the following directory:"
      puts "  #{File.expand_path(File.dirname(__FILE__))}."
      puts "Then, type in the filename like this: filename.txt"
      puts "The dates must be in the following format: MM/DD/YYYY."
      file_input ||= gets.chomp!
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
      elsif file_input.downcase == "help"
        help_command(__method__)
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

  def save_settings
    settings = { start_date: @start_date,
                 pay_interval: @pay_interval,
                 payday: @payday,
                 holiday_filename: @holiday_filename }
    File.open(".settings", "wb") do |file|
      file.write(settings.to_yaml)
    end
  end

  def load_settings
    File.open(".settings", "r") do |file|
      settings          = YAML.load(file.read)
      @start_date       = settings[:start_date]
      @pay_interval     = settings[:pay_interval]
      @payday           = settings[:payday]
      @holiday_filename = settings[:holiday_filename]
    end
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
    when :get_holiday_file
      puts ""
      puts "If you want to pass in a text file with holidays in it, type yes."
      puts "Then, put that file in the same directory as this script, which is:"
      puts "  #{File.expand_path(File.dirname(__FILE__))}"
      puts "Then, type in the file's name, for example, filename.txt"
      puts "The dates in the file must be on separate lines, like:\n#{Date.today.strftime('%m/%d/%Y')}\n#{Date.today.next_day.strftime('%m/%d/%Y')}"
      puts "If a date is not recognized, it will be ignored. The date format is MM/DD/YYYY."
      puts ""
    end
    method(sender_method).call
  end
end
