require 'spec_helper'

describe Oslc::Core::Query::LiteralValue, type: :lib do

  def result_for_value(value)
    ::Oslc::Core::Query::LiteralValue.new(value).parse
  end

  it 'should return content from string with quotation' do
    result_for_value('"23"').should eq("23")
    result_for_value('"foo bar"').should eq("foo bar")
  end

  it 'should return number from string without quotation' do
    result_for_value('23').should eq(23)
    result_for_value('.3').should eq(0.3)
    result_for_value('2.').should eq(nil)
    result_for_value('2.3').should eq(2.3)
    result_for_value('2.3e5').should eq(nil)
  end

  it 'should return boolean string' do
    result_for_value('true').should eq('true')
    result_for_value('false').should eq('false')
    result_for_value('invalidfalse').should eq(nil)
    result_for_value('"true"').should eq('true')
    result_for_value('"false"').should eq('false')
  end

  it 'should return only string without langtag option' do
    result_for_value('dog@en').should eq(nil)
    result_for_value('"dog"@en').should eq('dog')
    result_for_value('""@en').should eq('')
    result_for_value('"egz@mple"@en').should eq('egz@mple')
  end

  it 'should return only string when is used "prefixedName" option' do
    result_for_value('computer^^xsd:string').should eq(nil)
    result_for_value('"computer"^^xsd:string').should eq('computer')
    result_for_value('"^^xsd:string"^^xsd:string').should eq('^^xsd:string')
    result_for_value('"^^xsd:boolean"^^xsd:boolean').should eq(nil)
    result_for_value('"true"^^xsd:boolean').should eq('true')
    result_for_value('"false"^^xsd:boolean').should eq('false')
    result_for_value('"13"^^xsd:integer').should eq(13)
    result_for_value('"1.3"^^xsd:integer').should eq(nil)
    result_for_value('"http://example.com"^^xsd:anyUri').should eq('<http://example.com>')
    result_for_value('"^^rdf:XMLLiteral2"^^rdf:XMLLiteral').should eq('^^rdf:XMLLiteral2')
    result_for_value('"1.3"^^xsd:decimal').should eq(1.3)
    result_for_value('"1.3e-1"^^xsd:decimal').should eq(nil)
    result_for_value('"-1.3e-3"^^xsd:double').should eq(-0.0013)
    result_for_value('"2015-07-29T10:58:12Z"^^xsd:dateTime').should eq('2015-07-29T10:58:12Z')
  end
end
