module CfgHelper
  include RailsExtras::Helpers::Tag

  def alert_icons_for(*args)
    add_tag do |tag|
      if args.include?(:agent)
        tag.space 'Agent'
        if Tmt::Agent::Machine.working?
          tag.space icon('ok-sign', style: 'color: #5cb85c')
        else
          tag.space icon('warning-sign', style: 'color: #d9534f')
        end
      end
    end
  end
end
