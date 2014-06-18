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

  context '#get_start_date' do
    it 'should reset if invalid date format is passed' do
      expect(controller).to receive(:invalid_date_reset)
      controller.send(:get_start_date, "07/02/14")
    end
    it 'should reset if invalid date is passed' do
      expect(controller).to receive(:invalid_date_reset)
      controller.send(:get_start_date, "07/33/2014")
    end
    it 'should save an inputted date' do
      controller.send(:get_start_date, "07/02/2014")
      expect(controller.instance_eval { @start_date }).to eq(Date.strptime("07/02/2014", '%m/%d/%Y'))
    end
    it 'should set the default date as today if no date given' do
      controller.send(:get_start_date, "")
      expect(controller.instance_eval { @start_date }).to eq(Date.today)
    end
  end

  context '#invalid_date_reset' do
    it 'should call #get_start_date' do
      expect(controller).to receive(:get_start_date)
      controller.send(:invalid_date_reset)
    end
  end
end

describe PayrollCalculator do
  it "should be a class" do
    expect(PayrollCalculator.new).to be_an_instance_of(PayrollCalculator)
  end
end
