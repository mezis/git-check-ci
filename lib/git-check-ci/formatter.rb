

module GitCheckCI
  module Formatter
    extend self

    def handle_response(data)
      # binding.pry
      # !is_git_dir?             and draw(:gray, "?") and return
      # Config.ci.url.empty?     and draw(:gray, "?") and return
      # Config.ci.project.empty? and draw(:gray, "?") and return

      case data[:body]
        when /failed/         then build_string(:red,    '✗')
        when /pending/        then build_string(:gray,   '-')
        when /[0-9a-f]{40}/   then build_string(:green,  '✔')
        else build_string(:yellow, '!')
      end
    end


    private


    def build_string(color, symbol)
      reset  = "\033[0m"
      color_code = case color
        when :red    then "\033[7;31m"
        when :green  then "\033[7;32m"
        when :yellow then "\033[7;33m"
        when :gray   then "\033[7;37m"
      end

      "#{color_code}#{symbol}#{reset}"
    end


  end
end