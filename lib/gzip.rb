# encoding: utf-8

module Tmt
  module Lib
    class Gzip
      require 'zlib'

      def self.decompress_from(file_path)
        zstream = Zlib::Inflate.new
        buf = zstream.inflate(File.open(file_path, 'rb').read)
        zstream.finish
        zstream.close
        buf
      end

      def self.compress_to(file_path, string='example')
        z = ::Zlib::Deflate.new(::Zlib::DEFAULT_COMPRESSION)
        dst = z.deflate(string, ::Zlib::FINISH)
        z.close
        ::File.open(file_path, 'wb') do |f|
          f << dst
        end
      end

    end
  end
end
