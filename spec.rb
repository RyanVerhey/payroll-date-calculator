require 'rspec'
require_relative 'payroll_calc'

describe PayrollController do
  let(:controller) { PayrollController.new }
  let(:test_controller) { PayrollController.new(Date.today, "weekly", 5) }

  it "should be a class" do
    expect(PayrollController.new).to be_an_instance_of(PayrollController)
  end

  context '#run' do
    it 'should call #get_start_date, #get_pay_interval, #get_payday, and #print_list_of_dates' do
      expect(test_controller).to receive(:get_start_date)
      expect(test_controller).to receive(:get_pay_interval)
      expect(test_controller).to receive(:get_payday)
      expect(test_controller).to receive(:print_list_of_dates)
      test_controller.run
    end
    it 'shouldn\'t call #get_payday if the interval is "daily".' do
      test_controller = PayrollController.new(Date.today, "daily", 5)
      expect(test_controller).not_to receive(:get_payday)
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
      expect(controller.instance_eval { @payday }).to eq(3)
    end
    it 'should accept valid days regardless od case' do
      controller.send(:get_payday, "ThUrSdAy")
      expect(controller.instance_eval { @payday }).to eq(4)
    end
    it 'should make Friday the default if no specific day is geven' do
      controller.send(:get_payday, "")
      expect(controller.instance_eval { @payday }).to eq(5)
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
  it 'should have a readable @holidays variable' do
    expect(PayrollCalculator.holidays).to eq([])
  end
  it 'should have a writable @holidays variable' do
    PayrollCalculator.holidays << 1
    expect(PayrollCalculator.holidays.first).to eq(1)
  end

  context '.calculate' do
    it 'should return an array of formatted dates' do
      start_date = Date.strptime('07/02/2014', '%m/%d/%Y')
      date_arr = PayrollCalculator.calculate(start_date, "weekly", 5, nil, 1)
      expect(date_arr).to eq(['07/04/2014',
                              '07/11/2014',
                              '07/18/2014',
                              '07/25/2014',
                              '08/01/2014'])
    end
    it 'should start from the next payday if the start date is not a payday' do
      start_date = Date.strptime('07/05/2014', '%m/%d/%Y')
      date_arr = PayrollCalculator.calculate(start_date, "weekly", 5, nil, 1)
      expect(date_arr).to eq(['07/11/2014',
                              '07/18/2014',
                              '07/25/2014',
                              '08/01/2014'])
    end
    it 'should move on to the next day if the pay interval is daily and the date is not a valid payday' do
      start_date = Date.strptime('07/04/2014', '%m/%d/%Y')
      date_arr = PayrollCalculator.calculate(start_date, "daily", start_date.wday, nil, 1)
      expect(date_arr[0]).to eq('07/04/2014')
      expect(date_arr[1]).to eq('07/07/2014')
    end
    it 'should move to the next day if pay interval is daily and the day is a holiday' do
      start_date = Date.strptime('06/23/2014', '%m/%d/%Y')
      PayrollCalculator.holidays = [Date.strptime('06/24/2014', '%m/%d/%Y')]
      date_arr = PayrollCalculator.calculate(start_date, "daily", start_date.wday, nil, 1)
      expect(date_arr[0]).to eq('06/23/2014')
      expect(date_arr[1]).to eq('06/25/2014')
    end
    it 'should return to regular payday schedule if payday lands on a holiday or weekend' do
      start_date = Date.strptime('06/23/2014', '%m/%d/%Y')
      PayrollCalculator.holidays = [Date.strptime('06/30/2014', '%m/%d/%Y')]
      date_arr = PayrollCalculator.calculate(start_date, "weekly", start_date.wday, nil, 2)
      expect(date_arr[0]).to eq('06/23/2014')
      expect(date_arr[1]).to eq('06/27/2014')
      expect(date_arr[2]).to eq('07/07/2014')
    end
  end

  context ".invalid_payday?" do
    it 'should return true if the date is an invalid payday' do
      expect(PayrollCalculator.invalid_payday?(Date.strptime('06/21/2014', '%m/%d/%Y'))).to be(true)
    end
  end

  context ".import_holidays" do
    it 'should import dates from a file' do
      PayrollCalculator.holidays = []
      File.open("tmp.txt", "wb") do |f|
        f.write("07/02/2014\n07/03/2014")
      end
      PayrollCalculator.import_holidays("tmp.txt")
      expect(PayrollCalculator.holidays).to eq([Date.strptime("07/02/2014", '%m/%d/%Y'), Date.strptime("07/03/2014", '%m/%d/%Y')])
      File.delete("tmp.txt")
    end
  end
end
