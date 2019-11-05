module Tmt
  module Lib
    # Convert some structure to html
    # At the momemnt class can convert for:
    #   squence (xml) to html
    #   html (user can remove 'script' content) to html
    #   text/plain to html
    class Converter
      include ActionView::Helpers::TagHelper
      include ActionView::Context
      require 'erb'

      attr_reader :error
      def initialize(content, converter=nil)
        @content = content
        @converter = converter
        @error = nil
      end

      def self.list
        ['sequence', 'html', 'text/plain']
      end

      # If is defined parser for file extension than we can see file in html view
      def to_html(params={})
        content = case @converter
        when 'sequence'
          content = sequence_to_html
        when 'html'
          content = html_to_html(params)
        when 'html_without_js'
          content = html_to_html_without_js(params)
        when 'text/plain'
          content = ActiveSupport::SafeBuffer.new("#{ERB::Util.html_escape @content}")
        else
          content = ActiveSupport::SafeBuffer.new('')
        end
        ::Tmt::Lib::Encoding.to_utf8(content)
      rescue => e
        @error = e
        ActiveSupport::SafeBuffer.new('')
      end

      private

      # Return content of body node
      def html_to_html(params={})
        doc = Nokogiri::HTML(@content)
        #raise doc.errors.join(', ') if doc.errors.any?
        doc = doc.css('body').first
        return raw('') unless doc

        doc.css('body').each do |element|
          element.name = 'div'
        end
        doc.name = 'div' if doc.name == 'body'

        if params[:replace]
          params[:replace].each do |key, value|
            doc.name = value.to_s if key.to_s == doc.name
            doc.css(key.to_s).each do |element|
              element.name = value.to_s
            end
          end
        end
        doc.css('script').map(&:remove)
        raw doc
      end

      # Return content of body node
      def html_to_html_without_js(params={})
        doc = Nokogiri::HTML(@content)
        doc.css('script').map(&:remove)
        raw doc
      end

      def subsequence_to_html(tag, node)
        node.find('step').each do |step|
          tag << add_tag(:ul, class: 'list-unstyle') do |tag|
            tag << add_tag(:li) do |tag|
              tag << add_tag(:h4, style: 'color: #789abc') { step.attr('name') }
                tag << add_tag(:span, style: 'margin-left: 20px; font-weight: bold') { 'Type' }
                tag << add_tag(:span, style: 'margin-left: 10px') { step.attr('typename') }
                [
                  ['Description', step.find('Description').find('value')],
                  ['Comment', step.find('comment')],
                  ['PostExpr', step.find('PostExpr').find('value')],
                  ['SFPath', step.find('SFPath').find('value')],
                  ['Sequence Name', step.find('SeqName').find('value')]
                ].each do |name, object|
                  if object.any?
                    if not name.blank?
                      tag << add_tag(:div, class: 'empty-line') {' '}
                      tag << add_tag(:span, style: 'margin-left: 20px; font-weight: bold;') { name }
                      tag << add_tag(:span, style: 'margin-left: 10px') { object.text }
                    end
                  end
                end
            end
          end
        end
      end

      def sequence_to_html
        sequence = ::Tmt::HTML::Node.new(@content).find('data').find('sequence')
        return nil if sequence.empty?
        style = 'color: #345678'
        add_tag(:div) do |tag|
          tag << add_tag(:h2, style: style) do |tag|
            tag << 'Setup'
          end
          tag << add_tag(:p) do |tag|
            subsequence_to_html(tag, sequence.find('Setup'))
          end
          tag << add_tag(:h2, style: style) do |tag|
            tag << 'Main'
          end
          tag << add_tag(:p) do |tag|
            subsequence_to_html(tag, sequence.find('Main'))
          end
          tag << add_tag(:h2, style: style) do |tag|
            tag << 'Cleanup'
          end
          tag << add_tag(:p) do |tag|
            subsequence_to_html(tag, sequence.find('Cleanup'))
          end
        end
      end

      def add_tag(name, options={}, &block)
        if block_given?
          if block.arity == 1
            result = ActiveSupport::SafeBuffer.new
            block.call(result)
            content_tag(name, options) { result }
          else
            content_tag(name, options) { block.call }
          end
        end
      end

      def raw(content)
        ActiveSupport::SafeBuffer.new(content.to_s).html_safe
      end
    end
  end
end
