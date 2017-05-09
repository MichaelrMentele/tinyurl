require 'rails_helper'

describe Base62 do
  describe "self.to_base_62" do
    # base 62 in this case is 0-9a-Z
    it "correctly converts to base 62" do
      tmp = Base62
      expect(tmp.to_base_62(1)).to eq("1")
      expect(tmp.to_base_62(62)).to eq("10")
      expect(tmp.to_base_62(125)).to eq("21")
      expect(tmp.to_base_62(8453)).to eq("2cl")
    end
  end

  describe "self.to_base_10_from_62" do
    it "correctly converts to base 10 from 62" do 
      tmp = Base62
      expect(tmp.to_base_10_from_62('0')).to eq(0)
      expect(tmp.to_base_10_from_62('abc')).to eq(39134)
    end
  end
end
