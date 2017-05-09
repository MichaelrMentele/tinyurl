class Base62
  BASE_62_CHARS = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a

  def self.to_base_10_from_62(to_convert)
    # abc -> 11 * 62^2 + 12 * 62 ^ 1 + 13 * 62 ^ 0
    base_10 = 0
    to_convert.chars.reverse.each_with_index do |digit, power|
      base_10_val = BASE_62_CHARS.index(digit)
      base_10 += base_10_val.to_i * 62 ** power
    end

    base_10
  end

  def self.to_base_62(to_convert)
    # Take the log with a base of our charset of the number we are converting.
    # If x = 3 then we know we need 62^0 + 62^1 + 62^2 + 62^3
    # ex. log(8, base 2) = 3, we need 4 digits: 1000
    max_pwr = Math.log(to_convert, BASE_62_CHARS.length).floor

    base_62_str = ''
    prev_remainder = to_convert
    (max_pwr).downto(0) do |power|
      # see how many times the current base ^ power divides into the remaining
      # value. index into the char set at that number of divisions. This is
      # a number in the range 0..Z * 62^power.
      r = prev_remainder.divmod(BASE_62_CHARS.length ** power)
      base_62_str << BASE_62_CHARS[r[0]]
      prev_remainder = r[1]
    end
    base_62_str
  end
end
