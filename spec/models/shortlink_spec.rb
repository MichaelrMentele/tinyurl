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
