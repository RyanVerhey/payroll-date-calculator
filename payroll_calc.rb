require 'date'

class PayrollController
  def initialize
    @start_date = nil
    @pay_interval = nil
    @payday = nil
  end

end

class PayrollCalculator
  @@holidays = []

end

controller = PayrollController.new
