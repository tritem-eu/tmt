module Tmt
  module Lib
    class Encoding
      def self.to_utf8(content)
        begin
          # Try it as UTF-8 directly
          cleaned = content.dup.force_encoding('UTF-8')
          unless cleaned.valid_encoding?
            cleaned = cleaned.encode('UTF-8', 'Windows-1252')
          end
          cleaned
        rescue EncodingError
          # Force it to UTF-8, throwing out invalid bits
          content.encode!('UTF-8', invalid: :replace, undef: :replace)
        end
      end
    end
  end
end
