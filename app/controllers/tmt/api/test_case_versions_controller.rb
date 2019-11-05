# encoding: utf-8

module Tmt
  module Api
    class TestCaseVersionsController < ApplicationController
      # HTTP Basic Authentication SHOULD do so only via SSL
      before_action :http_basic_authenticate
      skip_before_filter :verify_authenticity_token

      # POST /api/projects/1/test_cases/1/versions.json
      def create
        file = params[:datafile][0]
        @test_case = ::Tmt::TestCase.find(params[:test_case_id])
        @project = @test_case.project

        authorize! :lead, @test_case
        authorize! :no_lock, @test_case
        @version = Tmt::TestCaseVersion.new({
          test_case_id: @test_case.id,
          datafile: file,
          comment: %{Uploaded file: #{file.original_filename}}
        })
        # remove prefix
        @version.datafile.original_filename = @version.datafile.original_filename.gsub(/^[0-9]*-/, '')
        @version.author = current_user

        respond_to do |format|
          if @version.save
            Tmt::UserActivity.save_for_version(@project, @test_case, current_user, @version)
            format.json { render json: @version.to_json }
          else
            format.json { render json: { errors: @version.errors.as_json} }
          end
        end
      end

      # POST /api/projects/1/test_cases/1/versions/check-md5.json
      def check_md5
        begin
          @test_case = ::Tmt::TestCase.find(params[:test_case_id])
          @project = @test_case.project
          authorize! :lead, @test_case
          authorize! :no_lock, @test_case
        rescue
          return (render json: { is_error: true }.to_json)
        end
        @version = @test_case.versions.order(created_at: :desc).first

        is_another = (@version.nil? or @version.md5 != params[:md5])
        render json: { is_another: is_another, is_error: false}.to_json
      end

      private

      def set_version
        @version = Tmt::TestCaseVersion.find(params[:id])
        @test_case = @version.test_case
        @project = @test_case.project
      end

    end
  end
end
