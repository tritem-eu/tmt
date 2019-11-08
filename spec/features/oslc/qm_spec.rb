require 'spec_helper'

# Bug: 301
feature "Oslc Basic authentication" do
  let(:project) { create(:project) }

  let(:user) do
    user = create(:user)
    project.add_member(user)
    user
  end

  scenario "application should remember old session" do
    sign_in user
    page.should have_content(user.email)
    visit oslc_qm_service_provider_path(project, format: :rdf)
    page.body.should include('</rdf:RDF>')
    visit root_path
    page.should have_content(user.email)
  end

end
