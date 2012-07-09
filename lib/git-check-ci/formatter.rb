

module GitCheckCI
  module Formatter
    extend self

    def handle_response(data)
      case data[:body]
        when /failed/              then [ color_code(:red),    '✗' ]
        when /(pending|building)/  then [ color_code(:gray),   '•' ]
        when /[0-9a-f]{40}/        then [ color_code(:green),  '✔' ]
        else [ color_code(:yellow), '!' ]
      end
    end


    private


    def color_code(color)
      reset  = "\033[0m"
      color_code = case color
        when :red    then "\033[31m"
        when :green  then "\033[32m"
        when :yellow then "\033[33m"
        when :gray   then "\033[37m"
        else ""
      end
    end


  end
end
