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


    def check_and_save(hash = nil)
      save(check(hash))
    end

    def uid
      @config.ci.project
    end


    private


    def check( hash = nil )
      return {:code => 400} if @config.ci.url.empty? || @config.ci.project.empty?

      login    = @config.ci.login
      password = @config.ci.password
      options  = {}
      unless login.empty? && password.empty?
        options[:basic_auth] = { :username => login.to_s, :password => password.to_s }
      end
      unless hash
        url = "#{@config.ci.url}/#{@config.ci.project}/ping"
      else
        url = "#{@config.ci.url}/#{@config.ci.project}/build_by_hash/#{hash}/ping"
      end
      response = HTTParty.get(url, options)
      return {:code => response.code, :body => response.to_s}

    rescue HTTParty::UnsupportedURIScheme, SocketError, Errno::ECONNREFUSED
      {:code => 400}
    end



    # save the CI result to the Git config
    def save(code_and_response)
      color, icon = Formatter.handle_response(code_and_response)
      @config.ci.last_checked = Time.now.strftime('%s')
      @config.ci.response     = code_and_response.to_json
      @config.ci.color        = color
      @config.ci.status       = icon
      nil
    end

  end
end
