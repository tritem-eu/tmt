module Tmt
  class ExternalRelationshipsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_source, only: [:new, :create]

    # GET /external-relationships/1
    def show
      @external_relationship = ::Tmt::ExternalRelationship.find(params[:id])
      @source = @external_relationship.source
      authorize! :lead, @source

      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    end

    # GET /test-cases/3/external-relationships/new
    # GET /test-cases/3/external-relationships/new.js
    def new
      authorize! :lead, @source
      @external_relationship = ::Tmt::ExternalRelationship.new
      respond_to do |format|
        format.html
        format.js {render layout: false}
      end
    end

    # GET /external_relationships/1/edit
    def edit
      @external_relationship = ::Tmt::ExternalRelationship.find(params[:id])
      @source = @external_relationship.source
      authorize! :lead, @source

      respond_to do |format|
        format.html
        format.js {render layout: false}
      end
    end

    # POST /test-cases/3/external_relationships
    # POST /test-cases/3/external_relationships.js
    def create
      @external_relationship = ::Tmt::ExternalRelationship.new(external_relationship_params)
      @external_relationship.source = @source
      authorize! :lead, @source
      authorize! :no_lock, @source

      respond_to do |format|
        if @external_relationship.save
          notice_successfully_created(@external_relationship, :also_now)
          format.html { redirect_to path(@source) }
          format.js { js_reload_page }
        else
          format.html { render 'new' }
          format.js { render 'new' }
        end
      end
    end

    # PATCH/PUT /external_relationships/1
    # PATCH/PUT /external_relationships/1.json
    def update
      @external_relationship = ::Tmt::ExternalRelationship.find(params[:id])
      @source = @external_relationship.source
      authorize! :lead, @source
      authorize! :no_lock, @source

      respond_to do |format|
        if @external_relationship.update(external_relationship_params)
          notice_successfully_updated(@external_relationship, :also_now)
          format.html { redirect_to path(@source) }
          format.js { js_reload_page }
        else
          format.html { render 'edit' }
          format.js { render 'edit' }
        end
      end
    end

    # DELETE /external-relationships/1
    # DELETE /external-relationships/1.js
    def destroy
      @external_relationship = ::Tmt::ExternalRelationship.find(params[:id])
      @source = @external_relationship.source
      authorize! :lead, @source
      @external_relationship.destroy

      respond_to do |format|
        notice_successfully_destroyed(@external_relationship, :also_now)
        format.html { redirect_to path(@source) }
        format.js {js_reload_page }
      end
    end

    private

    def set_source
      @source = params[:source_type].constantize.find(params[:source_id])
    end

    def external_relationship_params
      params.require(:external_relationship).permit(:value, :url, :rq_id, :kind)
    end

    def path(source)
      path = source.project
      path = [source.project, source] if source.kind_of?(TestCase)
      path
    end
  end
end
