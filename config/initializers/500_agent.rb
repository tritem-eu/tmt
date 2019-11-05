Tmt::Agent::Machine.create_directories
if [:production, :development].include?(Rails.env.to_sym)
  class Binding
    def pry
      Tmt::Agent::Config.unblocked = false
      super
      Tmt::Agent::Config.unblocked = true
    end
  end

  -> do
    begin

      # Administrator does this consciously (only for server version)
      return if ENV["AGENT"].nil?
      # How many process are running at the moment?
      pids = `ps aux | grep -v grep | grep "bin/rails s" | awk '{print $2}'`.lines.map(&:to_i).select do |pid|
        (`readlink -e '/proc/#{pid}/cwd'`.strip == Rails.root.to_s)
      end

      raise(StandardError, 'Im memory exist rails application in production environment') if pids.size > 1
    rescue => e
      logger = Logger.new(File.join(Rails.root, "log", "agent-#{Rails.env.to_sym}.log"))
      logger.warn("uncaught #{e} exception while handling connection: #{e.message}")
      return false
    end

    # Don't duplicate thread
    thread_name = "AgentMachine"
    return if Thread.list.map{|thread| thread["name"]}.include?(thread_name)
    Thread.new do
      Thread.current["name"] = thread_name
      agent = Tmt::Agent::Machine.new
      is_saved_pid = ::Tmt::Agent::Machine.save_pid(Process.pid)

      while true
        begin
          while sleep 5
            raise "Not saved new Process" unless is_saved_pid
            agent.poke if Tmt::Agent::Config.unblocked?
          end
        rescue => e
          logger = Logger.new(File.join(Rails.root, "log", "agent-#{Rails.env.to_sym}.log"))
          logger.error("uncaught #{e} exception while handling connection: #{e.message}")
          logger.error("Stack trace: #{e.backtrace.map {|l| "  #{l}\n"}.join}")
        end
        sleep 60
      end
    end

  end.call
end
