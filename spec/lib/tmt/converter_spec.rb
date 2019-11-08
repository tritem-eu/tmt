require 'spec_helper'
require 'rexml/document'
require 'converter'
describe Tmt::Lib::Converter do

  let(:html_content) do
    %Q{<html><head><script>alert('example')</script><style>b {background: #abcdef}</style></head><body><h2>Header</h2></body></html>}
  end

  let(:sequence_content) do
    upload_file('short.seq').read
  end

  it "should show list of converters" do
    Tmt::Lib::Converter.list.should eq(['sequence', 'html', 'text/plain'])
  end

  describe "#to_html" do
    it "should convert html to html without params" do
      Tmt::Lib::Converter.new(html_content, 'html').to_html().should eq('<div><h2>Header</h2></div>')
    end

    it "should convert html to html" do
      Tmt::Lib::Converter.new(html_content, 'html').to_html.should eq('<div><h2>Header</h2></div>')
    end

    it "should convert html to html with 'replace' argument" do
      Tmt::Lib::Converter.new(html_content, 'html').to_html(replace: {h2: :h1}).should eq('<div><h1>Header</h1></div>')
    end

    it "should convert html to html with plain text" do
      Tmt::Lib::Converter.new('Example text', 'html').to_html.should eq('<div><p>Example text</p></div>')
    end

    it "should convert text/plain to html" do
      Tmt::Lib::Converter.new('text plain example', 'text/plain').to_html.should eq('text plain example')
    end
  end
end
