require 'git-check-ci/config'
require 'git-check-ci/formatter'
require 'singleton'
require 'sha1'

require 'rubygems'
require 'httparty'

module GitCheckCI
  class Checker

    attr_reader :config

    # pass a :dir (defaults to current directory)
    def initialize(options = {})
      @directory = options[:dir] || Dir.pwd
      @config = Config.new(:dir => @directory)
    end


    def check_and_save
      save(check)
    end

    def uid
      @config.ci.project
    end


    private


    def check
      return {:code => 400} if @config.ci.url.empty? || @config.ci.project.empty?

      login    = @config.ci.login
      password = @config.ci.password
      options  = {}
      unless login.empty? && password.empty?
        options[:basic_auth] = { :username => login.to_s, :password => password.to_s }
      end
      url = "#{@config.ci.url}/#{@config.ci.project}/ping"
      response = HTTParty.get(url, options)
      return {:code => response.code, :body => response.to_s}

    rescue HTTParty::UnsupportedURIScheme, SocketError
      {:code => 400}
    end



    # save the CI result to the Git config
    def save(code_and_response)
      @config.ci.last_checked = Time.now.strftime('%F %T')
      @config.ci.response     = code_and_response.to_json
      @config.ci.status       = Formatter.handle_response(code_and_response)
      nil
    end

  end
end
