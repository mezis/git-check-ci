require 'git-check-ci/config'
require 'git-check-ci/server'
require 'git-check-ci/formatter'

require 'rubygems'
require 'thor'

module GitCheckCI
  class Shell < Thor
    include Thor::Actions

    desc "check [SHA]", "Fetch and print the current CI status."
    def check(hash = nil)
      Checker.new.check_and_save(hash)
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
      @config.ci.last_checked = nil
    end


    desc "server_start", "Start the checking daemon. Will store the build status in your git config."
    method_option :quiet, :type => :boolean, :aliases => "-q"
    def server_start
      Server.new.start options
    end

    desc "server_stop", "Stop the checking daemon."
    method_option :quiet, :type => :boolean, :aliases => "-q"
    def server_stop
      Server.new.stop options
    end

    desc "server_status", "Displays the server status."
    def server_status
      if Server.new.running?
        say "Server is running"
      else
        say "Server is not running"
      end
    end


    desc "init", "Output shell config."
    def init
      puts %q[
        _git_ci_color() {
          git config ci.color 2>&1 || true
        }
        _git_ci_status() {
          # exit early if not in a git repository
          git status > /dev/null 2>&1 || return

          # exit early if no project is configured
          git config ci.project > /dev/null 2>&1 || { echo '?' ; return ; }

          # spawn a server if no recent updates
          last_checked=$(git config ci.last-checked || echo 0)
          now=$(date +%s)
          let "delta = $now - $last_checked"
          test $delta -gt 120 && { git check-ci server_start & }

          # try to return a status
          git config ci.status 2> /dev/null || echo '?'
        }
        GitCheckCI() {
          echo "*** GitCheckCI is deprecated, use _git_ci_status"
          _git_ci_status
        }
      ]
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