def external_logger
  Logger.new(Rails.root.join('log', 'info.log'))
end
