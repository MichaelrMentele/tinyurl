class Shortlink < ActiveRecord::Base
  after_save :add_slug!

  validates :destination, :url => true
  validates :slug, uniqueness: true

  def slug=(str)
    if slug.present?
      raise "That path exists."
    else
      self[:slug] = str
    end
  end

  private

  def add_slug!
    update_attribute(:slug, Base62.to_base_62(id)) unless slug.present?
  end
end
