require 'rspec'
require_relative 'payroll_calc'

describe PayrollController do
  let(:controller) { PayrollController.new }

  it "should be a class" do
    expect(PayrollController.new).to be_an_instance_of(PayrollController)
  end

  context '#run' do
    it 'should call #get_start_date, get_pay_interval' do
      expect(controller).to receive(:get_start_date)
      expect(controller).to receive(:get_pay_interval)
      controller.run
    end
  end
end

describe PayrollCalculator do
  it "should be a class" do
    expect(PayrollCalculator.new).to be_an_instance_of(PayrollCalculator)
  end
end
