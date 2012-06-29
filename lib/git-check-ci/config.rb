# 
# Access Git settings by calling +git config+.
# 
# config.foo.bar returns the "bar" setting in section "foo".
#
require 'pathname'

module GitCheckCI
  class Config

    # configs are directory (well, repo) specific
    def initialize(options = {})
      @directory = options[:dir] || Dir.pwd
      @chain     = options[:chain] || []
      @default   = options[:default]
    end

    def to_s
      @to_s ||= get(@chain.join('.'), @default)
    end

    def method_missing(method_name, *args)
      if "string".respond_to?(method_name)
        to_s.send(method_name, *args)
      elsif method_name.to_s =~ /(.*)=$/
        set(@chain + [$1], *args)
      else
        options = args.first || {}
        self.class.new(options.merge :dir => @directory, :chain => @chain + [method_name])
      end
    end


    def self.method_missing(method_name, *args)
      new :chain => [method_name]
    end


    def self.is_git_dir?
      in_dir do
        %x(git status 2>/dev/null)
        ($? == 0)
      end
    end


    private


    def set(key, value, options={})
      in_dir do
        %x(git config #{key} "#{value}" 2>/dev/null)
        ($? == 0)
      end
    end

    def get(key, default=nil)
      in_dir do
        value = %x(git config #{key} 2>/dev/null).strip
        value.empty? ? default : value
      end
    end


    def in_dir
      old_dir = Dir.pwd
      begin
        Dir.chdir(@directory)
        yield
      ensure
        Dir.chdir(old_dir)
      end
    end

  end
end