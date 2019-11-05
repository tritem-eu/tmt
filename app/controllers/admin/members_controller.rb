module Admin
  class MembersController < ApplicationController
    before_action :authenticate_user!

    before_action :set_member, only: [:destroy]

    # GET /admin/member
    def index
      authorize! :manage, Tmt::Member

      @members = Tmt::Member.all
      @projects = Tmt::Project.all
      if @projects.any?
        @project_id = (params[:project_id] || @projects.first.id).to_i
        @users = User.undeleted
        @members_with_objects = Tmt::Member.members_with_objects(@project_id)
      end
    end

    # POST /admin/member
    def create
      authorize! :manage, Tmt::Member

      @member = Tmt::Member.where(member_params).first_or_initialize
      @member.is_active = true
      respond_to do |format|
        if @member.save
          Admin::MemberMailer.attached_to_project(current_user, @member.user, @member.project).deliver
          project_id = @member.project.id
          format.html { redirect_to admin_members_url(project_id: project_id) }
        else
          format.html { redirect_to admin_members_url }
        end
      end
    end

    # DELETE admin/members/1
    def destroy
      authorize! :manage, Tmt::Member
      project_id = @member.project.id
      @member.set_inactive if @member
      redirect_to admin_members_url(project_id: project_id)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Tmt::Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:project_id, :user_id)
    end
  end
end
