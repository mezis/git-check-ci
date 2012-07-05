require 'git-check-ci/config'
require 'git-check-ci/server'
require 'git-check-ci/formatter'

require 'rubygems'
require 'thor'

module GitCheckCI
  class Shell < Thor
    include Thor::Actions

    desc "fast-check", "Return a character for the current CI status. Usable in your prompt."
    def foo
      raise "This should never be reached."
    end

    desc "check", "Fetch and print the current CI status."
    def check
      Checker.new.check_and_save
      $stdout.puts Config.ci.response.to_s
    end

    desc "setup", "Interactively setup #{File.basename $0}."
    def setup
      Server.new.stop
      @config = Config.new

      ask_for @config.ci.url,      "What is the URL of your CI server?"
      ask_for @config.ci.project,  "What is the name of the project you're checking?"
      ask_for @config.ci.login,    "If the server requires a login, what should I use?"
      unless @config.ci.login.empty?
        ask_for @config.ci.password, "with which passphrase?"
      end

      puts
      say "Setup is now complete. Doing a test run."
      @config.ci.status = nil
      Checker.new.check_and_save
      if @config.ci.status.empty?
        say "Sorry, but something went wrong. Try checking connectivity and your setup.", :yellow
      else
        say "All good! Now the 'check' and 'fast-check' commands should work.", :green
      end
    end


    namespace :server

    desc "server_start", "Start the checking daemon."
    def server_start
      Server.new.start
    end

    desc "server_stop", "Stop the checking daemon."
    def server_stop
      Server.new.stop
    end

    desc "server_status", "Displays the server status."
    def server_status
      if Server.new.running?
        say "Server is running"
      else
        say "Server is not running"
      end
    end



    private


    def ask_for(setting, message)
      current_value = setting.get
      current_value = 'currently unset' if current_value.empty?
      puts
      value = ask("#{message} [#{current_value}]\n> ", :cyan)
      setting.set(value) unless value.empty?
    end

  end
end