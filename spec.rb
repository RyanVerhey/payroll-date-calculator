require 'rspec'
require_relative 'payroll_calc'

describe PayrollController do
  it "should be a class" do
    expect(PayrollController.new).to be_an_instance_of(PayrollController)
  end
end

describe PayrollCalculator do
  it "should be a class" do
    expect(PayrollCalculator.new).to be_an_instance_of(PayrollCalculator)
  end
end
