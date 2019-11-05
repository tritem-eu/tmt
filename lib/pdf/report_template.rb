# encoding: utf-8
# Generate Report about TestRun model using 'prawn' gem
module Tmt
  module Lib
    class PDF
      class ReportTemplate

        attr_reader :pdf, :params

        UNIVERSAL_COLOR = 'aaaaff'
        SECTION_COLOR = '8888dd'
        TABLE_COLOR = 'e0e0e0'

        def initialize(options={})
          @pdf = ::Prawn::Document.new(options)
          @pdf.font_families.update("DejaVuSans" => {
            :normal => "app/assets/fonts/DejaVuSans.ttf",
            :bold => "app/assets/fonts/DejaVuSans-Bold.ttf",
            :italic => "app/assets/fonts/DejaVuSans-Oblique.ttf",
            :bold_italic => "app/assets/fonts/DejaVuSans-BoldOblique",
          })
          @pdf.font("DejaVuSans")

          @bounds = @pdf.bounds
          @sections_counter = 0
          @subsections_counter = 0
          @tables_counter = 0

          @params = {
            header: {
              text_height: 15,
              logo_width: 100,
              logo_height: 15,
              first_column_width: 100
            },
            body: {
              first_column_width: 50,
              second_column_width: @bounds.width - 50
            },
            footer: {
              first_column_width: 100,
              second_column_width: @bounds.width - 100 - 100
            }
          }
        end

        def sections(&block)
          @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top - 40], :width => @pdf.bounds.width, height: @pdf.bounds.height - 2*20 - 40) do
            if block_given?
              block.call
            end
          end
        end

        def section(title, &block)
          @sections_counter += 1
          @subsections_counter = 0

          @pdf.text("#{@sections_counter}. #{title}", color: SECTION_COLOR, size: 20)
          @pdf.indent(@params[:body][:first_column_width]) do
            if block_given?
              block.call(@pdf)
            end
          end
          @pdf.move_down(40)
        end

        def subsection(title, &block)
          @subsections_counter += 1
          @pdf.indent(0 - @params[:body][:first_column_width]) do
            @pdf.text("#{@sections_counter}.#{@subsections_counter}. #{title}", color: SECTION_COLOR, size: 15)
          end
          block.call(@pdf) if block_given?
          @pdf.move_down(40)
        end

        def paragraph(name, &block)
          @pdf.move_down(15)
          @pdf.text(name, style: :bold, size: 14)
          if block_given?
            block.call
          end
        end

        def table(data, options={})
          @pdf.move_down(5)
          @pdf.table(data,
            width: @params[:body][:second_column_width],
            cell_style: { border_color: TABLE_COLOR, border_width: 1 },
            header: true
          ) do |table|
            table.row(0).background_color = TABLE_COLOR
            table.row(0).height = 15
            table.row(0).padding = [0, 5, 0, 5]
            table.row(0).align = :center
            text_color_for = [['Passed', '005500'], ['Failed', '550000'], ['Skip', 'a9a9a9'], ['Error', '555500']],
            background_color_for = [['Passed', 'aaffaa'], ['Failed', 'ff3333'], ['Skip', 'a9a9a9'], ['Error', 'aa0000']]

            if options[:default_text_color_for]
              values = table.cells.columns(0..-1).rows(0..-1)
              text_color_for.each do |value, color|
                values.filter do |cell|
                  cell.content == value
                end.text_color = color
              end
            end
            if options[:default_background_color_for]
              values = table.cells.columns(0..-1).rows(0..-1)
              background_color_for.each do |value, color|
                values.filter do |cell|
                  cell.content == value
                end.background_color = color
              end
            end
            if options[:valign]
              if options[:valign].class == Array
                options[:valign].each_with_index do |option, index|
                  table.column(index).valign = option if option
                end
              end
            end

           #if options[:align]
           #  if options[:align].class == Array
           #    options[:align].each_with_index do |option, index|
           #      table.column(index).valign = option if option
           #    end
           #  end
           #end

            if options[:column_width]
              if options[:column_width].class == Array
                options[:column_width].each_with_index do |option, index|
                  table.column(index).width = option if option
                end
              end
            end
          end

          if options[:title]
            @tables_counter += 1
            @pdf.move_down(5)
            @pdf.text("Tab. #{@tables_counter}: #{options[:title]}", size: 10)
          end
        end

        def add_footer(options={})
          @pdf.repeat :all do
            height = 15
            first_width = @params[:footer][:first_column_width]
            second_width = @params[:footer][:second_column_width]

            @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.bottom + 30], :width => @pdf.bounds.width, :height => 1) do
              @pdf.float do
                @pdf.fill_color 'aaaaff'
                @pdf.fill_rectangle [0, 0], @pdf.bounds.width, 0.5
              end
            end
           @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.bottom + 20], :width => @pdf.bounds.width, :height => 2*height) do
              @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top], :width => first_width, height: height) do
                @pdf.text options[:left_text], :align => :center, valign: :center, size: 10, color: '000000'
              end
              @pdf.bounding_box([@pdf.bounds.left + @params[:header][:first_column_width], @pdf.bounds.top], :width => second_width, height: 2*height) do
                @pdf.text_box options[:right_text], :align => :center, valign: :center, size: 10, color: '000000', :overflow => :shrink_to_fit
              end
           end
          end
        end

        def header(options={})
          @pdf.repeat :all do
            @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top], :width => @pdf.bounds.width, :height => 2*@params[:header][:text_height]) do
              header_logo(options[:logo_path])
              header_title(options[:title])
            end
            header_subtitle(options[:subtitle])
          end
        end

        def header_logo(logo_path)
          @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top], :width => @params[:header][:first_column_width], height: @params[:header][:text_height]) do
            if logo_path
              @pdf.image(logo_path, width: @params[:header][:logo_width], height: @params[:header][:logo_height] )
            end
          end
        end

        def header_title(title)
          @pdf.bounding_box([@pdf.bounds.left + @params[:header][:first_column_width], @pdf.bounds.top], :width => @pdf.bounds.width - @params[:header][:first_column_width], height: @params[:header][:text_height], border_style: :solid) do
            @pdf.float do
              @pdf.fill_color UNIVERSAL_COLOR
              @pdf.fill_rectangle [0, @pdf.bounds.height], @pdf.bounds.width, @pdf.bounds.height
            end
            @pdf.text(title, color: 'ffffff', align: :right, size: 10, valign: :bottom)
          end
        end

        def header_subtitle(subtitle)
          @pdf.bounding_box([@pdf.bounds.left + @params[:header][:first_column_width], @pdf.bounds.top - @params[:header][:text_height] ], :width => @pdf.bounds.width - @params[:header][:first_column_width], height: @params[:header][:text_height]) do
            @pdf.text(subtitle, color: '000000', align: :right, size: 8, valign: :center)
          end
        end

        def number_pages
          options = { :at => [0, 15],
            :align => :right,
            :page_filter => lambda{ |page| page > 1 },
            :start_count_at => 2,
            :color => "000000"
          }
          @pdf.number_pages "page <page> / <total>", options
        end

        def render
          @pdf.render
        end
      end
    end
  end
end
