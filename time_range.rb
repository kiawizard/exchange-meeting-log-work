class TimeRange
  def initialize(st, et)
    @start_time = st
    @end_time = et
  end

  def start_time
    @start_time
  end
  def start_time=(new_val)
    @start_time = new_val
  end

  def end_time
    @end_time
  end
  def end_time=(new_val)
    @end_time = new_val
  end

  def overlaps?(another_range)
    (self.start_time <= another_range.start_time && self.end_time >= another_range.start_time) ||
    (another_range.start_time <= self.start_time && another_range.end_time >= self.start_time)
  end

  def consume(another_range)
    self.start_time = [self.start_time, another_range.start_time].min
    self.end_time = [self.end_time, another_range.end_time].max
  end
  
  def length_minutes
    (self.end_time-self.start_time)/60
  end

  def to_s
    "#{start_time.strftime('%H:%M')}-#{end_time.strftime('%H:%M')}"
  end
end