class Shortlink < ActiveRecord::Base
  BASE_62_CHARS = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a

  def self.last_id
    last ? id : 0
  end

  after_save :add_slug!

  validates :destination, :url => true

  def to_base_62(to_convert)
    digits_needed = Math.log(to_convert, BASE_62_CHARS.length).floor + 1

    base_62_str = ''
    prev_remainder = to_convert
    (digits_needed - 1).downto(0) do |power|
      r = prev_remainder.divmod(BASE_62_CHARS.length ** power)
      base_62_str << BASE_62_CHARS[r[0]]
      prev_remainder = r[1]
    end
    base_62_str
  end

  private

  def add_slug!
    update_attribute(:slug, to_base_62(id))
  end
end
