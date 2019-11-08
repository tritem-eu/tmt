require 'spec_helper'
require 'encoding'

describe ::Tmt::Lib::Encoding do

  it ".to_utf8 without error" do
    invalid_content = %Q{start \xc3\x28 stop}
    invalid_content.valid_encoding?.should be false
    ::Tmt::Lib::Encoding.to_utf8(invalid_content).should eq('start Ã( stop')
  end

  it ".to_utf8 with error" do
    String.any_instance.stub(:force_encoding) { raise EncodingError }
    ::Tmt::Lib::Encoding.to_utf8('RíEÿ').should eq('RíEÿ')
  end


end
