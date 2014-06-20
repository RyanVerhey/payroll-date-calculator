require 'date'
require 'yaml'
require_relative '.date_extension'
require_relative '.payroll_controller'
require_relative '.payroll_calculator'

controller = PayrollController.new
controller.run
