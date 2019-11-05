# encoding: utf-8
# Generate Report about TestRun model using 'prawn' gem
module Tmt
  module Lib
    class PDF
      class TestRunReport
        require_relative 'report_template'

        attr_reader :pdf

        def initialize(test_run, options={}, &block)
          @template = ::Tmt::Lib::PDF::ReportTemplate.new(options)
          @pdf = @template.pdf
          @params = @template.params
          @test_run = test_run
          @creator_name = @test_run.creator.name

          @project = @test_run.project
        end

        def render
          @template.header({
            logo_path: Rails.root.join('app', 'assets', 'images', 'logo.png'),
            title: "Testreport #{@test_run.name}",
            subtitle: 'Test report of the automated testing'
          })

          @template.add_footer({
            left_text: 'TMT',
            right_text: "#{@project.name} Test report #{@test_run.name} V 1.0 Confidential and proprietary"
          })

          frontpage

          @template.sections do
            first_section
            second_section
            third_section
          end

          @template.number_pages
          @template.render
        end

        def parse_html(content)
          result = []
          item = 0
          doc = ::Nokogiri::HTML(::Tmt::Lib::Encoding.to_utf8(content))
          doc.css('table').each do |table|
            item += 1
            table_result = {}
            table.css('tr').each_with_index do |tr, index|
              tds = tr.css('td')
              if tds[0]
                if index == 0
                  table_result[:title] = tds[0].text.strip
                end
                item += 1
                case tds[0].css('span').text.strip
                when /status/i
                  table_result[:status] = tds[1].text.strip
                when /description/i
                  table_result[:description] = tds[1].text.strip
                else
                end

              end
            end
            if table_result.keys.sort == [:description, :status, :title]
              table_result[:description] = "#{table_result[:title]}\n#{table_result[:description]}"
              result << table_result
            end
          end
          result
        end

        private

        def parse_time(hours, minutes, seconds)
          "#{("00" + hours.to_s).last(2)}:#{("00" + minutes.to_s).last(2)}:#{("00" + seconds.to_s).last(2)}"
        end

        def first_section
          @template.section('About this document') do |pdf|
            pdf.text("This document is the report of the automatic tested requirements.
            Here are the testcases from the testrun #{@test_run.name}
            documented.")
          end
        end

        # return requirements of test run
        def second_section
          @template.section('Overview of proven requirements') do |pdf|
            pdf.text %Q{In the following table are the automatic tested requirements with the results
            listed. Detailed information about tested requirement are in chapter "testreport
            of proven requirements}

            custom_field_values = @test_run.custom_field_values
            if custom_field_values.any?
              data = [['name', 'value']]
              custom_field_values.each do |custom_field_value|
                data << [custom_field_value.custom_field.name, custom_field_value.value.to_s]
              end
              @template.paragraph("Custom Fields") do
                @template.table(data, title: "Custom Fields" )
              end
            end
            @template.paragraph("Results") do
              data = [['Requirement', 'Result']]
              @test_run.executions.each do |execution|
                result = execution.status.to_s.humanize
                requirement = execution.test_case.name
                data << [requirement, result]
              end
              @template.table(data, {
                title: "Results",
                default_text_color_for: true,
                default_background_color_for: true
              })
            end
          end
        end

        # return rendered content of result file
        def third_section
          @template.section('Testreports of proven requirements') do
            @test_run.executions.each do |execution|
              result = execution.status.to_s.humanize
              test_case_name = execution.test_case.name

              @template.subsection(test_case_name) do
                @template.paragraph("Result") do
                  @template.table([[result]], {
                    default_text_color_for: true,
                    default_background_color_for: true
                  })
                end
                relationships = execution.version.test_case.external_relationships
                if relationships.any?
                  @template.paragraph("Relationships") do
                    data = [['Name', 'Value']]
                    relationships.each do |relationship|
                      data << [relationship.value, relationship.url]
                    end
                    @template.table(data)
                  end
                end
                @template.paragraph("Execution") do
                  total_seconds = execution.updated_at - execution.created_at
                  hours = (total_seconds/ 3600).to_i
                  minutes = ((total_seconds % 3600) / 60).to_i
                  seconds = ((total_seconds % 3600) % 60).to_i
                  @template.table([
                    ['', 'Dates'],
                    ['Execution date', execution.created_at.to_s[0..9]],
                    ['Execution time', execution.created_at.to_s[10..18]],
                    ['Execution duration [H:M:S]', parse_time(hours, minutes, seconds)],
                    ['Execution status', execution.status],
                    ['Sequence comment', execution.comment]
                  ])
                end
                attached_file = execution.attached_files[0]
                if attached_file and attached_file[:compressed_file]
                  @template.paragraph("TestCaseses") do
                    data = [['TestCase', 'Result']]
                    parse_html(attached_file[:compressed_file].decompress).each do |element|
                      data << [element[:description], element[:status]]
                    end
                    @template.table(data,
                      {column_width: [nil, 60], valign: [nil, :center]}
                    )
                  end
                end
              end
            end
          end
        end

        def frontpage
          @pdf.bounding_box([@pdf.bounds.left, @pdf.bounds.top - 40], :width => @pdf.bounds.width, height: @pdf.bounds.height - 2*20 - 40) do
            @pdf.bounding_box([@pdf.bounds.left + @params[:body][:first_column_width], @pdf.bounds.top - 40], :width => @pdf.bounds.width - @params[:body][:first_column_width], height: @pdf.bounds.height - 2*20 - 40) do
              @pdf.table([
                [{content: 'Testreport:', size: 14}, {content: @test_run.name, size: 14}],
                ['Project:', @project.name],
                ['Document type:', 'Test report of the automated testing'],
                ['Document id:', @test_run.id],
              ], :row_colors => ["fcfcfc", "ffffff"],
                 width: @params[:body][:second_column_width],
                 :cell_style => {border_width: 0, font_style: :bold}
              )
              @pdf.move_down(80)
              @template.table([
                ['', 'Name', 'Date', 'Signum'],
                ['prepared', @creator_name, '', ''],
                ['checked', 'x', '', ''],
                ['approved', 'x', '', '']
              ])
              @template.table([
                ['Language', 'Version'],
                ['En', '1.0']
              ])
            end
          end
          @pdf.start_new_page

        end

      end
    end
  end
end
