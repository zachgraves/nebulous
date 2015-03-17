module Nebulous
  class Row
    def self.map(str, *args)
      opts = args.extract_options!
      headers = new(str, *args)
      map = opts.fetch(:mapping, headers)
      headers.zip(map).to_h
    end

    def initialize(str, *args)
      opts = args.extract_options!

      str.gsub!(opts[:comment_exp], '')
      str.chomp!

      begin
        data = CSV.parse_line str, opts.slice(:col_sep, :row_sep, :quote_char)
      rescue CSV::MalformedCSVError
        exp = /(#{opts[:col_sep]})(?=(?:[^"]|"[^"]*")*$)/
        data = str.gsub(exp, "\0").split(/\0/)
      end

      data.map(&:strip)
    end
  end
end
