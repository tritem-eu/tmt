require 'spec_helper'
require 'pdf/test_run_report'

describe ::Tmt::Lib::PDF::TestRunReport do
  include CommonHelper
  let(:report_html) { upload_file('main_sequence_Report.html').read }
  let(:project) { create(:project, name: 'example') }
  let(:campaign) { create(:campaign, project: project) }
  let(:execution) { create(:execution, test_run: test_run) }
  let(:test_run) { create(:test_run, campaign: campaign) }
  let(:test_case) { execution.version.test_case }
  let(:external_relationship) { create(:external_relationship, source: test_case) }

  let(:pdf) { Tmt::Lib::PDF::TestRunReport.new(test_run, {:margins=>[0, 0, 0, 0], :paper=>"A5"} ) }

  before do
    clean_execution_repository
    external_relationship
    execution
  end

  describe '#parse_html' do
=begin
    it "should parse test_run with no custom fields" do
      pdf.parse_html(report_html).should include({
        :title => "Statement",
        :status => "Done",
        :description => "Statement\nStationGlobals.ForceResetAtNextStartup = False"
      })
    end
=end
    it "should parse test_run with invalid encoding" do
      pdf.parse_html("<html>
        <table>
          <tr><td>Title</td></tr>
          <tr>
            <td><span>status</span></td>
            <td>Status\xFC with invalid encoding</td>
          </tr>
          <tr>
            <td><span>description</span></td>
            <td><span>Description</span></td>
          </tr>
        </table>
      </html>").should include({
        title: "Title",
        status: "Statusü with invalid encoding",
        description: "Title\nDescription"
      })

    end
  end

  describe '#render' do

    it "should render test_run with no custom fields" do
      expect do
        pdf.render
      end.to_not raise_error
    end
=begin
    it "should return information from result html" do
      file = ""
      file.stub(:decompress) { report_html }
      Tmt::Execution.any_instance.stub(:attached_files) {[{compressed_file: file}]}
      result = ::PDF::Inspector::Text.analyze(pdf.render).strings
      result.should include "2 - Removes ALL variables from FastLog"
      result.should include "StationGlobals.MultiTractionConfigurations.ACIInterfaceHandlers[Loca"
    end
=end
    # Bug 247
    it "should render test_run with custom fields" do
      custom_field_value = Tmt::TestRunCustomFieldValue.create({
        test_run: test_run,
        custom_field: create(:test_run_custom_field_for_bool, project: project)
      })
      custom_field_value.value = '0'
      custom_field_value.save
      test_run.reload # Don't remove it!
      expect do
        pdf.render
      end.to_not raise_error
    end
  end

end
