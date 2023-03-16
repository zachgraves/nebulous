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
      opts = opts.to_h
      str.gsub!(opts[:comment_exp], '')
      str.chomp!

      begin
        args = opts.slice(:col_sep, :row_sep, :quote_char)
        data = CSV.parse_line str, **args
      rescue CSV::MalformedCSVError
        exp = /(#{opts[:col_sep]})(?=(?:[^"]|"[^"]*")*$)/
        data = str.gsub(exp, "\0").split(/\0/)
      end

      new data.map(&:to_s).map(&:strip)
    end

    def to_numeric
      arr = map do |val|
        case val
        when /^[+-]?\d+\.\d+$/
          val.to_f
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
