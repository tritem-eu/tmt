require 'spec_helper'

describe Oslc::Automation::ServiceProvidersController do
  extend CanCanHelper

  let(:xml) { Nokogiri::XML(response.body) }

  let(:admin) { create(:admin) }

  let(:john) do
    user = create(:user, name: 'John')
    project.add_member(user)
    user
  end

  let(:project) { create(:project,
    name: 'title - 29.10.2014 16:11',
    description: 'description - 29.10.2014 16:13'
  ) }

  before do
    ready(admin, john, project)
  end

  [[:rdf, 'application/rdf+xml'], [:xml, 'application/xml']].each do |format, accept|
    describe "GET index for format: #{format}" do
      it_should_not_authorize(self, [:no_logged], auth: :basic, format: format) do |options|
        request.headers[:accept] = accept
        get :index, format: options[:format]
      end

      it "should collect projects where current_user is John" do
        http_login(john)
        get :index, format: format
        spc = '//oslc:ServiceProviderCatalog'
        url = server_url "/oslc/automation/service-providers"
        xml.at_xpath(spc).attributes["about"].value.should eq url
        xml.at_xpath("#{spc}//dcterms:title").text.should eq('TMT Automation Service Provider Catalog')
        xml.at_xpath("#{spc}//dcterms:description").text.should eq('TMT Automation Service Provider Catalog.')
        xml.at_xpath("#{spc}//dcterms:publisher").should_not be_nil
        sp = "#{spc}//oslc:serviceProvider//oslc:ServiceProvider"
        url = server_url "/oslc/automation/service-providers/#{project.id}"
        xml.at_xpath(sp).attributes['about'].value.should eq url
        xml.at_xpath("#{sp}//dcterms:title").text.should eq(project.name)
        xml.at_xpath("#{sp}//dcterms:description").text.should eq(project.description.to_s)
        url = server_url("/projects/#{project.id}")
        xml.at_xpath("#{sp}//oslc:details").to_s.should eq("<oslc:details rdf:resource=\"#{url}\"/>")
      end
    end
  end

  [[:rdf, 'application/rdf+xml'], [:xml, 'application/xml']].each do |format, accept|
    it_should_not_authorize(self, [:no_logged], auth: :basic, format: format) do |options|
      request.headers[:accept] = accept
      get :show, id: project.id
    end

    describe "GET show for format: #{format}" do
      it "should collect projects where current_user is John" do
        http_login(john)
        request.headers[:accept] = accept
        get :show, id: project.id
        request.headers[:accept].should eq(accept)
        sp = '//oslc:ServiceProvider'
        url = server_url("/oslc/automation/service-providers/#{project.id}")
        xml.at_xpath(sp).to_s.should include("<oslc:ServiceProvider rdf:about=\"#{url}\">")
        xml.at_xpath("#{sp}//dcterms:title").text.should eq('title - 29.10.2014 16:11')
        xml.at_xpath("#{sp}//dcterms:description").text.should eq('description - 29.10.2014 16:13')
        xml.at_xpath("#{sp}//dcterms:publisher").should_not be_nil
        s = "#{sp}//oslc:service//oslc:Service"
        xml.at_xpath(s).to_s.should_not be_nil
        adapter_url = server_url("/oslc/automation/service-providers/#{project.id}/adapters")
        xml.at_xpath("#{s}//oslc:creationFactory//oslc:CreationFactory//oslc:creation").to_s.should eq("<oslc:creation rdf:resource=\"#{adapter_url}\"/>")
      end
    end
  end

end
