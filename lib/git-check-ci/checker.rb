require 'git-check-ci/config'
require 'singleton'
require 'httparty'
require 'sha1'

module GitCheckCI
  class Checker

    # pass a :dir (defaults to current directory)
    def initialize(options = {})
      @directory = options[:dir] || Dir.pwd
      @config = Config.new(:dir => @directory)
    end


    def check
      return [400,""] if @config.ci.url.empty? || @config.ci.project.empty?

      login    = @config.ci.login
      password = @config.ci.password
      options  = {}
      unless login.empty? && password.empty?
        options[:basic_auth] = { :username => login.to_s, :password => password.to_s }
      end
      url = "#{@config.ci.url}/#{@config.ci.project}/ping"
      response = HTTParty.get(url, options)
      # $stderr.puts "query #{url} -> #{response.code}"
      return [response.code,response.to_s]

    rescue HTTParty::UnsupportedURIScheme, SocketError
      return [400,""]
    end


    def uid
      # SHA1.hexdigest("#{@config.ci.url}/#{@config.ci.project}")
      @config.ci.project
    end

  end
end
