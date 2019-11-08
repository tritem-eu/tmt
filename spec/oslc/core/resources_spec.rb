require 'spec_helper'

describe Oslc::Core::Resources, type: :lib do

# let(:project) { create(:project, id: 123, name: 'example Project', description: 'Example description') }
# let(:project_1) { create(:project, id: 124, name: 'example Project 1') }
# let(:project_2) { create(:project, id: 224, name: 'example Project 2') }
# let(:project_225) { create(:project, id: 225, name: 'example Project 225') }

# class Oslc::QuerySyntaxRspec < Oslc::Core::QuerySyntaxForEntry
#   def initialize(options={})
#     options[:controller] = DummySpecController.new(format: :rdf)
#     super
#     @class_name = ::Tmt::Project
#   end
# end

# let(:query) do
#   Oslc::QuerySyntaxRspec.new({
#     oslc_select: '',
#     oslc_where: '',
#     class_name: Tmt::Project,
#     provider: project,
#     controller: DummySpecController.new()
#   })
# end

# let(:xml_handle) do
#   Tmt::XML::Klass.new('oslc:Property')
# end

# let(:dummy_controller) do
#   controller = 'controller'
#   def controller.user_url(entry)
#     "www.example.com/tmt/users/#{entry}"
#   end

#   def controller.oslc_qm_service_provider_test_case_url(project, entry)
#     "www.example.com/tmt/service-providers/#{project.id}/test-cases/#{entry.id}"
#   end
#   controller
# end

# before do
#   ready(project, project_1, project_2, project_225)
# end

# describe "#select when" do
#   it "select attribute of string parser" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:title',
#       oslc_where: "",
#       class_name: Tmt::Project,
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq('<oslc:Property><dcterms:title>example Project</dcterms:title></oslc:Property>')
#   end

#   it "select attribute of text parser" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:description',
#       oslc_where: "",
#       class_name: Tmt::Project,
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq('<oslc:Property><dcterms:description>Example description</dcterms:description></oslc:Property>')
#   end

#   it "select attribute of example_text parser" do
#     ::Tmt::Project.stub(:oslc_prefixed_name) do
#       {
#         "dcterms:exampleText" => {
#           parser: :example_text
#         }
#       }
#     end

#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:exampleText',
#       oslc_where: "",
#       class_name: Tmt::Project
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><dcterms:exampleText>Example text</dcterms:exampleText></oslc:Property>})
#   end

#   it "select attribute of oslc_qm_runs_test_case parser" do
#     execution = create(:execution)
#     test_case = execution.test_case
#     project = test_case.project
#     query = Oslc::Qm::TestExecutionRecord::QuerySyntax.new({
#       provider: project,
#       oslc_select: 'oslc_qm:runsTestCase',
#       oslc_where: '',
#       controller: DummySpecController.new(format: :rdf)
#     })
#     query.select(xml_handle, execution)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><oslc_qm:runsTestCase><oslc_qm:runsTestCase rdf:about="http://example.com:3001/prefix/oslc/qm/service-providers/#{project.id}/test-cases/#{test_case.id}" /></oslc_qm:runsTestCase></oslc:Property>})
#   end

#   it "doesn't select not defined attribute" do
#     execution = create(:execution)
#     ::Tmt::Project.stub(:oslc_prefixed_name) do
#       {
#         "oslc_qm:noAttribute" => {}
#       }
#     end

#     expect do
#       Oslc::QuerySyntaxRspec.new({
#         oslc_select: 'oslc_qm:noAttribute',
#         oslc_where: '',
#         class_name: Tmt::Project,
#       }).select(xml_handle, execution)
#     end.to raise_error(%Q{Used parser '', hence selector 'oslc_qm:noAttribute' of #{execution.to_s} cannot be parsed})
#   end

#   it "select attribute of date parser" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:created',
#       oslc_where: "",
#       class_name: Tmt::Project,
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><dcterms:created>#{project.created_at.iso8601}</dcterms:created></oslc:Property>})
#   end

#   it "select attribute of user parser" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:creator',
#       oslc_where: "",
#       class_name: Tmt::Project,
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><dcterms:creator rdf:resource="http://example.com:3001/prefix/admin/users/#{project.creator.id}" /></oslc:Property>})
#   end

#   it "select attribute of example_text parser" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: 'dcterms:creator',
#       oslc_where: "",
#       class_name: Tmt::Project,
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><dcterms:creator rdf:resource="http://example.com:3001/prefix/admin/users/#{project.creator.id}" /></oslc:Property>})
#   end

#   it "select all information about project" do
#     Oslc::QuerySyntaxRspec.new({
#       oslc_select: '*',
#       oslc_where: "",
#       class_name: Tmt::Project
#     }).select(xml_handle, project)
#     xml_handle.to_xml.should eq(%Q{<oslc:Property><dcterms:creator rdf:resource="http://example.com:3001/prefix/admin/users/#{project.creator.id}" /><dcterms:identifier>#{project.id}</dcterms:identifier><dcterms:title>example Project</dcterms:title><dcterms:description>Example description</dcterms:description><dcterms:created>#{project.created_at.iso8601}</dcterms:created></oslc:Property>})
#   end

# end

# describe "#simple_term when" do

#   it "syntax is empty" do
#     query.where('').should eq(::Tmt::Project.all)
#   end

#   it "syntax uses operation '='" do
#     query.where('dcterms:title="example Project"').should eq([project])
#   end

#   it "syntax uses operation '!='" do
#     query.where('dcterms:title!="example Project 1"').should eq([project, project_2, project_225])
#   end

#   it "syntax uses operation '<'" do
#     query.where('dcterms:identifier<"124"').should eq([project])
#   end

#   it "syntax uses operation '>'" do
#     query.where('dcterms:identifier>"124"').should eq([project_2, project_225])
#   end

#   it "syntax uses operation '<='" do
#     query.where('dcterms:identifier<="124"').should eq([project, project_1])
#   end

#   it "syntax uses operation '>='" do
#     query.where('dcterms:identifier>="124"').should eq([project_1, project_2, project_225])
#   end

#   it "syntax with invalid operation '!<'" do
#     expect do
#       query.where('dcterms:identifier!<"124"')
#     end.to raise_error(/Invalid query of syntax/)
#   end

#   it "syntax uses operation 'in '" do
#     query.where('dcterms:identifier in ["124", "225"]').should eq([project_1, project_225])
#   end

#   it "syntax uses operation 'in'" do
#     query.where('dcterms:identifier in["124", "225"]').should eq([project_1, project_225])
#   end

# end

# it "#compound_term with operator ' and '" do
#   query.where('dcterms:identifier>"123" and dcterms:title="example Project 1"').should eq([project_1])
# end

# describe "#parse_to_value when" do
#   it "have url value" do
#     query.where('dcterms:creator=<http://example.com/users/1>').should eq([project])
#   end

#   it "has not defined parser" do
#     ::Tmt::Project.stub(:oslc_prefixed_name) do
#       {
#         "oslc_qm:noAttribute" => {}
#       }
#     end

#     expect do
#       query.where('oslc_qm:noAttribut in [43]')
#     end.to raise_error
#   end

#   it "has not defined properly parser" do
#     ::Tmt::Project.stub(:oslc_prefixed_name) do
#       {
#         "oslc_qm:noAttr" => { parser: :text_}
#       }
#     end

#     expect do
#       query.where('oslc_qm:noAttr in ["value"]')
#     end.to raise_error
#   end

#   it "uses text parser" do
#     query.where('dcterms:description="Example description"').should eq([project])
#   end

#   it "uses date parser" do
#     query.where(%Q{dcterms:created!="#{Time.now.iso8601}"}).should_not be_empty
#   end

#   it "with invalid parser" do
#     expect do
#       query.where('dcterms:description=<http://example.com/users/1>')
#     end.to raise_error(%Q{Didn't defined parser for selector 'dcterms:description'})
#   end
# end

# it "#scoped_term with invalid prefixed name " do
#   expect do
#     query.where('dcterms:title{dcterms:identifier="1"}')
#   end.to raise_error("Invalid query")
# end

# it "shouldn't select records for wildcard and comarison_op" do
#   query.where('*=""').should be_empty
# end

# it "shouldn't select records for wildcard and in_op" do
#   query.where('*=[]').should be_empty
# end

end
