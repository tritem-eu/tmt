module Tmt
  module Lib
    class Pagination
      # It should give 2*radius-1 elements
      def self.array_for(total_pages, current_page, radius=4)
        if total_pages < 2*radius
          result = (1..total_pages).to_a
        else
          if current_page <= radius
            result = (1..2*radius-2).to_a
            result << nil
          elsif current_page >= total_pages-radius+1
            result = (total_pages-2*radius+3..total_pages).to_a
            result.unshift(nil)
          else
            result = (current_page-radius+2..current_page+radius-2).to_a
            result.push(nil)
            result.unshift(nil)
          end
        end
      end
    end
  end
end
