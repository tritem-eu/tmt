require 'spec_helper'

# describe Oslc::Core::QuerySyntaxForEntry, type: :lib do

#   class Oslc::QuerySyntaxRspec < Oslc::Core::QuerySyntax
#     def initialize(options={})
#       options[:controller] = DummySpecController.new()
#       super
#       @class_name = ::Tmt::Project
#       @pairs = @class_name.oslc_prefixed_name
#     end
#   end

#   describe "hash_of_oslc_where" do

#     it "for one selector with '!=' operator" do
#       oslc_where = "rqm_auto:taken!=true"
#       query_syntax = Oslc::Core::QuerySyntaxForEntry.new(oslc_where: oslc_where)
#       result = query_syntax.hash_of_oslc_where
#       result.should eq({"rqm_auto:taken" => {:operator=>"!=", :value=>"true", :type=>:comparison_op}})
#     end

#     it "for one selector with '=' operator" do
#       oslc_where = "rqm_auto:taken=false"
#       query_syntax = Oslc::Core::QuerySyntaxForEntry.new(oslc_where: oslc_where)
#       result = query_syntax.hash_of_oslc_where
#       result.should eq({"rqm_auto:taken" => {:operator=>"=", :value=>"false", :type=>:comparison_op}})
#     end

#     it "for one selector with '=' operator with 'url' value" do
#       oslc_where = "oslc:serviceProvider=<http://localhost:3000/oslc/auto/service-providers/3.xml>"
#       query_syntax = Oslc::Core::QuerySyntaxForEntry.new(oslc_where: oslc_where)
#       result = query_syntax.hash_of_oslc_where
#       result.should eq({"oslc:serviceProvider" => {:operator=>"=", :value=>"http://localhost:3000/oslc/auto/service-providers/3.xml", :type=>:comparison_op}})
#     end

#     it "for two selectors" do
#       oslc_where = "rqm_auto:taken='false' and dcterms:title!=example"
#       query_syntax = Oslc::Core::QuerySyntaxForEntry.new(oslc_where: oslc_where)
#       result = query_syntax.hash_of_oslc_where
#       result.should eq({
#         "rqm_auto:taken" => {operator: "=", value: "false", type: :comparison_op},
#         "dcterms:title"  => {operator: "!=", value: "example", type: :comparison_op}
#       })
#     end

#     it "for complex query" do
#       oslc_where = "rqm_auto:executesOnAdapter=<http://localhost:3000/oslc/execution.ToolAdapter> and rqm_auto:taken=false and oslc_auto:state=<http://open-services.net/ns/auto#canceled>"
#       query_syntax = Oslc::Core::QuerySyntaxForEntry.new(oslc_where: oslc_where)
#       result = query_syntax.hash_of_oslc_where

#       result.should eq({
#         "rqm_auto:executesOnAdapter"=> {:operator=>"=", :value=> "http://localhost:3000/oslc/execution.ToolAdapter",
#           :type=>:comparison_op},
#         "rqm_auto:taken" => {:operator=>"=", :value=>"false", :type=>:comparison_op},
#         "oslc_auto:state" => {:operator=>"=", :value=>"http://open-services.net/ns/auto#canceled",
#           :type=>:comparison_op}})
#     end

#   end
# end
