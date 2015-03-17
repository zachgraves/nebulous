module Nebulous
  class Parser
    DEFAULT_OPTIONS = {
      col_sep: nil,
      row_sep: nil,
      quote_char: '"',
      comment_exp: /^#/,
      chunk: false,
      headers: true,
      mapping: nil,
      limit: false,
      remove_empty_values: true,
      encoding: Encoding::UTF_8.to_s
    }

    attr_reader :file
    attr_reader :options

    def initialize(file, opts = {})
      @options = OpenStruct.new DEFAULT_OPTIONS.merge(opts)
      @file = read_input(file)

      merge_delimiters
    end

    def process(&block)
      headers = Row.map(readline, options) if options[:headers]
      while !file.eof?
        ln = readline
        # determine if current line has uneven quotes then read next line
        ln += readline if ln.count(options.quote_char) % 2
        row = Row.new(ln, options)
        hash = headers.zip(row).to_h
      end
    ensure
      file.rewind
    end

    def delimiters
      @delimiters ||= DelimiterDetector.new(@file.path).detect
    end

    private

    def read_input(input)
      input.respond_to?(:readline) ? input : File.open(input, "r:#{encoding}")
    end

    def readline
      file.readline(line_terminator).encode(encoding, invalid: :replace)
    end

    def encoding
      options.encoding
    end

    def merge_delimiters
      options.row_sep ||= delimiters[:row_sep]
      options.col_sep ||= delimiters[:col_sep]
    end

    def line_terminator
      options.row_sep
    end
  end
end
