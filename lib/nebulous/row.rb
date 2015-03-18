module Nebulous
  class Row
    def self.map(str, opts)
      headers = parse(str, opts).map(&:parameterize).map(&:underscore)
      map = opts.mapping.try(:values) || headers
      headers.zip(map).to_h
    end

    def self.parse(str, opts)
      str.gsub!(opts.comment_exp, '')
      str.chomp!

      begin
        args = opts.to_h.slice(:col_sep, :row_sep, :quote_char)
        data = CSV.parse_line str, args
      rescue CSV::MalformedCSVError
        exp = /(#{opts.col_sep})(?=(?:[^"]|"[^"]*")*$)/
        data = str.gsub(exp, "\0").split(/\0/)
      end

      data.map(&:strip)
    end
  end
end
