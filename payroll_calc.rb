require 'date'

class PayrollController
  def initialize
    @start_date = nil
    @pay_interval = nil
    @payday = nil
  end

  def run
    puts "Welcome to Ryan's Payroll Calculator!"
    puts ""
    get_start_date
    puts @start_date
    puts ""
    get_pay_interval
    puts @pay_interval
    puts ""
    get_payday
    puts @payday
    puts ""
    # print_list_of_dates(PayrollCalculator.calculate(@start_date, @pay_interval, @payday))
  end
end

class PayrollCalculator
  @@holidays = []

end

controller = PayrollController.new
controller.run
