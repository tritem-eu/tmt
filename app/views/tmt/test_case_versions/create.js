<% if @version.id %>
  window.reload();
<% else %>
  $("#new_test_case_version").replaceWith('<%= j render(
    partial: "/tmt/test_case_versions/form",
    locals: {
      version: @version,
      url: project_test_case_versions_path(@project, @test_case, @new_version)
    }
  ) %>')
  if (app._uploadFile.basket.length) {
    $('#new_test_case_version input[type="file"]').replaceWith(app._uploadFile.basket.last())
  }
  app._uploadFile.event();
  app.testCases.init().event.versionComment();
<% end %>
