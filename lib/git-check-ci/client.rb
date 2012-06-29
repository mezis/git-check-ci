require 'git-check-ci/server'
require 'json'

module GitCheckCI
  class Client

    def initialize(options = {})
      @dir    = options[:dir] || Dir.pwd
      @server = Server.new(:dir => @dir)
    end


    def read
      return [400,""] unless @server.outfile.exist?

      io = File.open(@server.outfile, 'r')
      begin
        io.flock File::LOCK_SH
        return JSON.parse io.read
      ensure
        io.flock File::LOCK_UN
        io.close
      end
    end

  end
end
