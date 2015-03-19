module Nebulous
  module Input
    module Delimiters
      def delimiters
        @delimiters ||= Nebulous::DelimiterDetector.new(file.path).detect
      end

      private

      def merge_delimiters
        options.row_sep ||= delimiters[:row_sep]
        options.col_sep ||= delimiters[:col_sep]
      end
    end
  end
end
