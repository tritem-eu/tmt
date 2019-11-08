require 'spec_helper'

describe Tmt::Dispenser do
  [
    [4, 7,     [1, 2, 3, 4, 5], true,  false],
    [6, 7,     [1, 2, 3, 4, 5], false, false],
    [6, 3,     [1, 2, 3],       false, true ],
    [6, 'all', [1, 2, 3, 4, 5], false, false],
    [3, '',    [1, 2, 3], false, true],
    [3, nil,   [1, 2, 3], false, true],
    [3, 4,     [1, 2, 3, 4], false, true],
    [3, 2,     [1, 2], false, true],
    [3, 'all', [1, 2, 3, 4, 5], true, false]
  ].each do |default_limit, limit, array, less, more|
    it "should retrun [1, 2, 3, 4, 5] array for '6' value of default limit variable and '7' value of limit variable" do
      dispenser = Tmt::Dispenser.new([1, 2, 3, 4, 5], default_limit, limit)
      dispenser.collection.should eq(array)
      dispenser.less?.should be(less)
      dispenser.more?.should be(more)
    end
  end
end
