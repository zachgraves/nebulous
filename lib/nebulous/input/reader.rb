module Nebulous
  module Input
    module Reader
      def read_input(input)
        input.respond_to?(:readline) ? input : File.open(input, "r:#{encoding}")
      end

      def read_complete_line
        ln = readline
        while ln.empty? || ln.count(options.quote_char) % 2 == 1
          ln += readline
        end
        ln
      end

      def readline
        file.readline(line_terminator).encode(encoding, invalid: :replace).chomp
      end

      def line_terminator
        options.row_sep
      end

      def encoding
        options.encoding
      end
    end
  end
end
