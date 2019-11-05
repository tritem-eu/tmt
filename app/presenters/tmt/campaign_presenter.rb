module Tmt
  class CampaignPresenter < ApplicationPresenter
    presents :campaign

    def created_at
      if campaign.created_at
        l(campaign.created_at, format: :medium)
      else
        content_or_none(nil)
      end
    end

    def deadline_at
      content_or_none(l(campaign.deadline_at, format: :medium))
    rescue
      content_or_none(nil)
    end

    def is_open
      add_tag do |tag|
        tag.space show_value(campaign.is_open?)
      end
    end

    def link_edit
      return unless campaign.is_open
      add_link(edit_admin_campaign_path(campaign), remote: true, title: t(:edit, scope: :campaigns)) do |content|
        content.space(icon 'pencil')
        content << t(:edit, scope: :campaigns)
      end
    end

    # link close the campaign
    def link_close
      if campaign.is_open
        if can? :lead, campaign
          link_to close_admin_campaign_path(campaign),
            method: :put,
            class: 'only-for-js',
            title: t(:close, scope: :campaigns),
            data: {confirm: "You can not re-open this campaign again!\nAre you sure?"} do
              add_tag do |tag|
                tag << icon('remove')
                tag.space(t :close, scope: :campaigns)
              end
          end
        end
      end
    end

  end
end
