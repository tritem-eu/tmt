require 'spec_helper'
describe Oslc::Core::SelectivePropertyValues::Properties, type: :lib do

  it "#parse" do
    oslc_properties = Oslc::Core::SelectivePropertyValues::Properties.new('dcterms:title,dcterms:creator{foaf:givenName,foaf:familyName{example:example}},dcterms:identifier')
    oslc_properties.parse.should match_array([
      ['dcterms:title'],
      ['dcterms:creator'],
      ['dcterms:creator', 'foaf:givenName'],
      ['dcterms:creator', 'foaf:familyName'],
      ['dcterms:creator', 'foaf:familyName', 'example:example'],
      ['dcterms:identifier']
    ])
  end

end
