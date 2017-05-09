class Shortlink < ActiveRecord::Base
  after_save :add_slug!

  validates :destination, :url => true
  validates :slug, uniqueness: true

  private

  def add_slug!
    update_attribute(:slug, Base62.to_base_62(id))
  end
end
