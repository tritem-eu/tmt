module Oslc
  module Core
    class Routes
      include Rails.application.routes.url_helpers

      def initialize(url_options=Tmt.config[:url_options])
        [:host, :port, :script_name, :protocol].each do |name|
          if url_options[name]
            default_url_options[name] = url_options[name]
          else
            default_url_options.delete(name)
          end
        end
        @host = self.root_url
        @routes = Rails.application.routes.url_helpers

        #if url_options[:script_name]
        #  @host = @host.gsub(/#{url_options[:script_name]}/, '')
        #end
        cover_urls_of_oslc_by_new
      end

      def self.get_singleton
        @@singleton ||= nil
        if @@singleton == nil
          @@singleton = self.new()
        end
        @@singleton
      end

      # This method covers old methods (which are defined by url_helpers module)
      # by new methods which is faster.
      def cover_urls_of_oslc_by_new
        methods = @routes.methods.delete_if {|element| not element.to_s =~ /^oslc_.*_path$/}
        methods.each do |method_name|
          array = @routes.method(method_name).call('.', '.', '.', '.').split('.')
          method_url = method_name.to_s.gsub(/_path$/, '_url')
          self.class.send(:define_method, method_url) do |*args|
            result = ''
            args.each_with_index do |arg, index|
              if defined?(arg.id)
                arg = arg.id
              end
              if arg.class == Hash
                arg = "?#{arg.to_query}"
              end
              result += "#{array[index]}#{arg}"
            end
            last_index = args.size
            if array[last_index]
              result += array[last_index]
            end
            @host.gsub(/\/$/, '') + '/' + result.gsub(/^\//, '')
          end
        end
      end

    end
  end
end
