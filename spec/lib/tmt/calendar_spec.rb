require 'spec_helper'
require 'calendar'

describe Tmt::Lib::Calendar do
  def parse_calendar(data)
    data.map do |row|
      row.map{ |day| day.nil? ? "" : day[:number] }
    end
  end

  describe ".generate_with" do
    it "for year: 2014 and month: 5" do
      parse_calendar(Tmt::Lib::Calendar.generate_with(2014, 5)).should eq(
      [
        ["", "", "", "", 1, 2, 3],
        [4, 5, 6, 7, 8, 9, 10],
        [11, 12, 13, 14, 15, 16, 17],
        [18, 19, 20, 21, 22, 23, 24],
        [25, 26, 27, 28, 29, 30, 31]
      ])
    end

    it "for year: 2014 and month: 6" do
      parse_calendar(Tmt::Lib::Calendar.generate_with(2014, 6)).should eq(
      [
        [1, 2, 3, 4, 5, 6, 7],
        [8, 9, 10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19, 20, 21],
        [22, 23, 24, 25, 26, 27, 28],
        [29, 30, "", "", "", "", ""]
      ])
    end

    it "for year: 2014 and month: 7" do
      parse_calendar(Tmt::Lib::Calendar.generate_with(2014, 7)).should eq(
      [
        ['', '', 1, 2, 3, 4, 5],
        [6, 7, 8, 9, 10, 11, 12],
        [13, 14, 15, 16, 17, 18, 19],
        [20, 21, 22, 23, 24, 25, 26],
        [27, 28, 29, 30, 31, "", ""]
      ])
    end

  end
end
