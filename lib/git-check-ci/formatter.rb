

module GitCheckCI
  module Formatter
    extend self
    
    def draw(color, symbol)
      reset  = "\033[0m"
      color_code = case color
        when :red    then "\033[7;31m"
        when :green  then "\033[7;32m"
        when :yellow then "\033[7;33m"
        when :gray   then "\033[7;37m"
      end

      $stdout.printf "#{color_code}#{symbol}#{reset}"
      true
    end


    def handle_response(code, message)
      # binding.pry
      # !is_git_dir?             and draw(:gray, "?") and return
      # Config.ci.url.empty?     and draw(:gray, "?") and return
      # Config.ci.project.empty? and draw(:gray, "?") and return

      case message
        when /failed/         then draw(:red,    '✗')
        when /pending/        then draw(:gray,   '-')
        when /[0-9a-f]{40}/   then draw(:green,  '✔')
        else draw(:yellow, '!')
      end
    end

  end
end