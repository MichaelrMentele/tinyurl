class ShortlinkDecorator
  attr_reader :base

  def initialize(base_url)
    @base = base_url
  end

  def prepend_base_url(shortlink)
    base + "/r/#{shortlink.slug}"
  end
end
