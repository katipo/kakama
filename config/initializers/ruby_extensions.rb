module NumberFormatters
  def to_two_digit
    "%02d" % self.to_s
  end
end

class String
  include NumberFormatters
end

class Fixnum
  include NumberFormatters
end
