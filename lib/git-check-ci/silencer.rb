module GitCheckCI
  module Silencer
    
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