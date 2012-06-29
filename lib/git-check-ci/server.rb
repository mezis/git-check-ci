require 'git-check-ci/checker'
require 'pathname'
require 'daemons'
require 'json'

module GitCheckCI
  class Server

    # path where the results are stored
    attr_reader :outfile

    def initialize(options = {})
      @dir      = options[:dir] || Dir.pwd
      @interval = options[:interval] || 60.0
      @checker  = Checker.new(:dir => @dir)
      @outfile  = tmpdir.join("#{app_name}.out")

      @appgroup = Daemons::ApplicationGroup.new(
        app_name,
        :multiple => false, :dir => tmpdir.to_s, :dir_mode => :normal
      )
      @app = @appgroup.new_application(:mode => :proc, :proc => method(:worker))
    end


    def start
      return if @app.running?
      work # once manually so we're pretty sure the server loop will work
      @app.start
      sleep 0.1 until @app.pid.pid
      @app.started
      nil
    end


    def stop
      @app.stop if @app.running?
      nil
    end
   

    def running?
      @app.running?
    end


    private


    def app_name
      "ci-check-#{@checker.uid}"
    end


    def worker
      $0 = app_name
      loop do
        work
        sleep @interval
      end
    end

    def work
      io = File.open(@outfile,'w')
      begin
        io.flock File::LOCK_EX
        io.write @checker.check.to_json
        io.flush
        nil
      ensure
        io.flock File::LOCK_UN
        io.close
      end
    end


    def tmpdir
      Pathname.new '/var/tmp'
    end

  end
end
