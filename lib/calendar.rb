module Tmt
  module Lib
    class Calendar

      def self.year_month_with(date, button)
        year = (date && date[:year].present? ? date[:year].to_i : Time.now.year)
        month = (date && date[:month].present? ? date[:month].to_i : Time.now.month)
        date = Date.new(year, month)
        date = date.next_month if button and button[:next]
        date = date.prev_month if button and button[:previous]
        [date.year, date.month]
      end

      def self.year_month_day_with(date, button)
        year = (date && date[:year].present? ? date[:year].to_i : Time.now.year)
        month = (date && date[:month].present? ? date[:month].to_i : Time.now.month)
        day = (date && date[:day].present? ? date[:day].to_i : Time.now.day)
        date = Date.new(year, month, day)
        date = date.next_day if button and button[:next]
        date = date.prev_day if button and button[:previous]
        [date.year, date.month, date.day]
      end

      def self.generate_with(year, month)
        date = Date.new(year, month, 1)
        calendar = []
        Time.days_in_month(month, year).times do
          calendar << [nil] * 7 if calendar[-1].nil? or date.wday == 0
          calendar[-1][date.wday] = {number: date.day}
          date += 1
        end
        calendar
      end

    end
  end
end
