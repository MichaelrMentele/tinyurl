class Shortlink < ActiveRecord::Base
  BASE_62_CHARS = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a

  after_save :add_slug!

  validates :destination, :url => true
  validates :slug, uniqueness: true

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

  private

  def add_slug!
    update_attribute(:slug, Shortlink.to_base_62(id))
  end
end
