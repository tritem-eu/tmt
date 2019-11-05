class Admin::MemberMailer < ActionMailer::Base
  default from: "from@example.com"

  def attached_to_project(sender, recipient, project)
    @sender = sender
    @project = project
    @recipient = recipient
    mail(to: recipient.email, subject: 'Attached to project')
  end

end
