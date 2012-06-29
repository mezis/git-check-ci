require 'git-check-ci/checker'
require 'git-check-ci/silencer'
require 'pathname'

require 'rubygems'
require 'daemons'
require 'json'

module GitCheckCI
  class Server
    include Silencer

    # path where the results are stored
    attr_reader :outfile

    def initialize(options = {})
      @dir      = options[:dir] || Dir.pwd
      @interval = options[:interval] || 60.0
      @checker  = Checker.new(:dir => @dir)

      @appgroup = Daemons::ApplicationGroup.new(
        app_name,
        :multiple => false, :dir => tmpdir.to_s, :dir_mode => :normal
      )
      @app = @appgroup.new_application(:mode => :proc, :proc => method(:worker))
    end


    def start(options = {})
      return if @app.running?
      work # once manually so we're pretty sure the server loop will work
      @app.start
      sleep 0.1 until @app.pid.pid
      @app.started unless options[:quiet]
      nil
    end


    def stop(options = {})
      return unless @app.running?
      if options[:quiet]
        silencing($stdout) { @app.stop }
      else
        @app.stop
      end
      nil
    end
   

    def running?
      @app.running?
    end


    private


    def app_name
      "git-check-ci:#{@checker.uid}"
    end


    def worker
      $0 = app_name
      loop do
        work
        sleep @interval
      end
    end

    def work
      @checker.check_and_save
    end


    def tmpdir
      Pathname.new '/var/tmp'
    end

  end
end
