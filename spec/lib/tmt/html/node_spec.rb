require 'spec_helper'

describe Tmt::HTML::Node do

  let(:sequence_content) { File.read(Rails.root.join('spec', 'files', 'main_sequence.seq')) }
  let(:step_content) { %Q{<Step typename='BT_ACI_CheckRawSystemValue' xsi:type='_CustomStepType_' name='2 - Checks value of the ACI system variable'>\n\t\t\t\t\t\t\t\t\t\t\t\t<subprops>\n\t\t\t\t\t\t\t\t\t\t\t\t\t<Description classname='Str'>\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t<value>Str(\"Save current distance from SS_XVh</value></Description>\n\t\t\t\t\t\t\t\t\t\t\t\t</subprops>\n\t\t\t\t\t\t\t\t\t\t\t</Step>} }

  let(:node) { Tmt::HTML::Node }

  describe ".position_tag" do
    it "without error" do
      node.new("<script> </script>").position_tag('script').should eq([0, 17])
      node.new("<scRipt> </script>").position_tag('script').should eq([0, 17])
      node.new("example<scRipt>alert('test') </scriPT>").position_tag('script').should eq([7, 37])
      node.new("example<scRipt language='javaScript'>alert('test') </scriPT> example").position_tag('script').should eq([7, 59])
      node.new("example<scRipt language='javaScript'>alert('test') </scriPT> example<script></script>").position_tag('script').should eq([7, 59])

      node.new("example<language='javaScript' scRipt>alert('test') </scriPT>").position_tag('script').should eq(nil)
      node.new("example< scRipt>alert('test') </scriPT> <div></div>").position_tag('script').should eq([7, 38])
      node.new("example< iscRipt>alert('test') </scriPT>").position_tag('script').should eq(nil)
      node.new("example< scRipt>alert('test') </scr").position_tag('script').should eq(nil)
      node.new("<html><script>alert('example')</script></html>").position_tag('html').should eq([0, 45])

      node.new("<html><script>alert('example')</script></html>").position_tag('script').should eq([6, 38])
      node.new("<html><script>alert('example')</script></html>").position_tag('script').should eq([6, 38])

      node.new("<html><script
          language='javaScript'
        >
        alert('example')
        </script>
        </html>").position_tag('script'
      ).should eq([6, 97])
    end

    it "with error" do
      node.new(Math).position_tag('script').should be_nil
    end
  end

  describe ".replace_tag!" do
    it "with one script" do
      content = "<html><script>alert('example')</script></html>"
      node.new(content).replace!('script')
      content.should eq("<html></html>")
    end

    it "without script" do
      content = "<html>alert('example')</html>"
      node.new(content).replace!('script')
      content.should eq("<html>alert('example')</html>")
    end

    it "with two script" do
      content = %Q{<html><script>alert('example')</script>
<div id='test'></div>
<script>alert('example')</script> </html>}
      node.new(content).replace!('script')
      content.should eq("<html>\n<div id='test'></div>\n </html>")
    end

  end
=begin
  it "#find" do
    node.new(sequence_content).find('data').should_not be_empty
    node.new(sequence_content).find('data').find('sequence').should have(1).item
    node.new(sequence_content).find('data').find('sequence').find('step')[1].find('description').first.content.should eq(%Q{<Description classname='Str'>\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t<value>Str(\"Save current distance from SS_XVhTravDstKm to local variable CrntTravDstkm\")</value>\n\t\t\t\t\t\t\t\t\t\t\t\t\t</Description>})
  end
=end
  it "#find with text method" do
    node.new('').find('data').text.should be_empty
  end

  describe "#attr" do
    it "without error" do
      node.new(step_content).attr('typename').should eq('BT_ACI_CheckRawSystemValue')
    end

    it "with error" do
      node.new(Math).attr('typename').should be_nil
    end
  end

  it "#text" do
    node.new(step_content).find('description').text.should eq(%Q{\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t<value>Str(\"Save current distance from SS_XVh</value>})
  end

end
