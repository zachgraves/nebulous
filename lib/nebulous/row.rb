module Nebulous
  class Row < Array
    def self.headers(str, opts)
      headers = parse(str, opts).
        map(&:parameterize).
        map(&:underscore).
        map(&:to_sym)
      headers.zip(headers).to_h
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

      data.map!(&:strip)
      new(data).to_numeric
    end

    def to_numeric
      arr = map do |val|
        case val
        when /^[+-]?\d+\.\d+$/
          val.to_i
        when /^[+-]?\d+$/
          val.to_i
        else
          val
        end
      end

      self.class.new(arr)
    end

    def merge(keys)
      return self unless keys
      keys.values.zip(self).to_h
    end
  end
end
