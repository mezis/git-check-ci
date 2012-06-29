# require 'git-check-ci/config'
require 'git-check-ci/server'
require 'git-check-ci/client'
require 'git-check-ci/formatter'
require 'thor'

module GitCheckCI
  class Shell < Thor

    desc "foo", "Prints foo"
    def foo
      puts "foo"
    end

    desc "start", "Start the checking daemon"
    def start
      Server.new.start
    end

    desc "stop", "Stop the checking daemon"
    def stop
      Server.new.stop
    end

    desc "status", "Print the current CI status"
    def status
      silencing($stdout) do
        Server.new.start
      end
      Formatter.handle_response(*Client.new.read)
    end


    private


    def silencing(stream)
      old_stream = stream.dup
      stream.reopen('/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end

  end
end