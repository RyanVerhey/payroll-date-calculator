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
