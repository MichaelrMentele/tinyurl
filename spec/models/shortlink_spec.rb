require 'rails_helper'

describe Shortlink do
  it "validates uniqueness of slug" do
    Shortlink.create!(destination: "http://randomstring.com")
    Shortlink.create!(destination: "http://randomstring.com")

    first = Shortlink.first
    expect { first.update!(slug: Shortlink.second.slug) }.to raise_error
  end

  it "validates that destination is a URL" do
    Shortlink.create(destination: "randomstring")
    expect(Shortlink.count).to eq(0)
  end

  describe "self.to_base_62" do
    # base 62 in this case is 0-9a-Z
    it "correctly converts to base 62" do
      Shortlink.create(destination: "http://www.example.com")
      tmp = Shortlink
      expect(tmp.to_base_62(1)).to eq("1")
      expect(tmp.to_base_62(62)).to eq("10")
      expect(tmp.to_base_62(125)).to eq("21")
      expect(tmp.to_base_62(8453)).to eq("2cl")
    end
  end

  describe "#after_save" do
    it "automatically creates a base 62 slug" do
      Shortlink.create(destination: "http://www.example.com")
      expect(Shortlink.first.slug).to eq("1")
    end

    it "correctly increments" do
      Shortlink.create(destination: "http://www.example.com")
      Shortlink.create(destination: "http://www.example.com")

      expect(Shortlink.last.slug).to eq("2")
    end

    it "correctly increments" do
      10.times { Shortlink.create(destination: "http://www.example.com") }

      expect(Shortlink.last.slug).to eq("a")
    end
  end
end
