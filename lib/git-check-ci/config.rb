# 
# Access Git settings by calling +git config+.
# 
# config.foo.bar returns the "bar" setting in section "foo".
#
require 'pathname'

module GitCheckCI
  class Config
    Error = Class.new(RuntimeError)

    
    # configs are directory (well, repo) specific
    def initialize(options = {})
      @directory = options.delete(:dir) || Dir.pwd
      @chain     = options.delete(:chain) || []
      @default   = options.delete(:default)
      raise Error.new("Bad options #{options.inspect}") if options.any?
    end

    def to_s
      @to_s ||= get
    end


    # return true when ci.url, ci.project, ci.status exist
    def valid?
      self.ci.url.to_s
      self.ci.project.to_s
      self.ci.status.to_s
      true
    rescue Error
      false
    end


    def method_missing(method_name, *args)
      if "string".respond_to?(method_name)
        # puts "passing #{method_name} to #{key}"
        to_s.send(method_name, *args)
      elsif method_name.to_s =~ /(.*)=$/
        # puts "passing #{method_name} to #{key}"
        self.class.new(:dir => @directory, :chain => @chain + [$1]).send(:set,*args)
      else
        options = args.first || {}
        self.class.new(options.merge :dir => @directory, :chain => @chain + [method_name])
      end
    end


    def is_git_dir?
      in_dir do
        %x(git status 2>/dev/null)
        ($? == 0)
      end
    end


    def self.method_missing(method_name, *args)
      new :chain => [method_name]
    end


    def self.valid?
      new.valid?
    end


    def set(value)
      # puts "writing config (#{key} -> #{value})"
      in_dir do
        if value.nil?
          %x(git config --unset #{key} || true)
        else
          %x(git config #{key} "#{value}")
        end
        raise Error.new("writing config failed (#{key} -> #{value})") unless ($? == 0)
      end
    end

    def get
      in_dir do
        value = %x(git config #{key}).strip
        # raise Error.new("reading git config failed (#{key})") unless ($? == 0)
        value.empty? ? (@default || "") : value
      end
    end


    private


    def key
      @chain.join('.').gsub(/_/,'-')
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