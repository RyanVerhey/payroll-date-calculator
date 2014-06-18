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

  context '#get_pay_interval' do
    it 'should reset if invalid interval is given' do
      expect(controller).to receive(:get_pay_interval)
      controller.send(:get_pay_interval, "Not an interval")
    end
    it 'should save valid pay interval if one is given' do
      controller.send(:get_pay_interval, "daily")
      expect(controller.instance_eval { @pay_interval }).to eq("daily")
    end
    it 'should accept valid intervals regardless of case' do
      controller.send(:get_pay_interval, "DAILY")
      expect(controller.instance_eval { @pay_interval }).to eq("daily")
    end
    it 'should make the default interval bi-weekly if none is given' do
      controller.send(:get_pay_interval, "")
      expect(controller.instance_eval { @pay_interval }).to eq("bi-weekly")
    end
  end

  context '#get_payday' do
    it 'should reset if invalid day of the week is given' do
      expect(controller).to receive(:get_payday)
      controller.send(:get_payday, "Not a day of the week")
    end
    it 'should save the day if a valid day of the week is given' do
      controller.send(:get_payday, "Wednesday")
      expect(controller.instance_eval { @payday }).to eq("wednesday")
    end
    it 'should accept valid days regardless od case' do
      controller.send(:get_payday, "ThUrSdAy")
      expect(controller.instance_eval { @payday }).to eq("thursday")
    end
    it 'should make Friday the default if no specific day is geven' do
      controller.send(:get_payday, "")
      expect(controller.instance_eval { @payday }).to eq("friday")
    end
  end

  context '#print_list_of_dates' do
    it 'prints a list of dates' do
      allow(controller).to receive(:puts) { anything() }
      expect(controller).to receive(:puts).with("07/02/2014").and_call_original
      expect(controller).to receive(:puts).with("08/02/2014").and_call_original
      controller.send(:print_list_of_dates, ["07/02/2014", "08/02/2014"])
    end
  end
end

describe PayrollCalculator do
  it "should be a class" do
    expect(PayrollCalculator.new).to be_an_instance_of(PayrollCalculator)
  end
end
