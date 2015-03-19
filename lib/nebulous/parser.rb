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
      encoding: Encoding::UTF_8.to_s
    }

    attr_reader :file
    attr_reader :options

    def initialize(file, *args)
      opts = args.extract_options!

      @options = OpenStruct.new DEFAULT_OPTIONS.merge(opts)
      @file = read_input(file)

      merge_delimiters
    end

    def process(&block)
      @index = 0
      read_headers
      iterate(&block)
    ensure
      reset
      file.rewind
    end

    def delimiters
      @delimiters ||= DelimiterDetector.new(file.path).detect
    end

    private

    def reset
      @index = 0
      @headers = nil
      @chunk = nil
    end

    def chunk
      @chunk ||= Chunk.new chunk_options
    end

    def read_headers
      @headers ||= Row.headers(readline, options) if options[:headers]
    end

    def iterate(&block)
      while !file.eof?
        break if limit?
        chunk << replace_keys(parse_row)
        yield_chunk(chunk, &block) if block_given? && options.chunk
      end

      @chunk.to_a
    end

    def sequence
      @index += 1
    end

    def limit?
      options.limit && options.limit == @index
    end

    def parse_row
      sequence
      Row.parse(read_complete_line, options).merge(@headers)
    end

    def yield_chunk(chunk, &_block)
      if chunk.full? || file.eof?
        yield chunk.map(&:to_a)
        @chunk = nil
      end
    end

    def read_input(input)
      input.respond_to?(:readline) ? input : File.open(input, "r:#{encoding}")
    end

    def read_complete_line
      ln = readline
      while ln.count(options.quote_char) % 2 == 1
        ln += readline
      end
      ln
    end

    def readline
      file.readline(line_terminator).encode(encoding, invalid: :replace).chomp
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

    def chunk_options
      Hash.new.tap do |attrs|
        attrs[:size] = options.chunk.to_i if options.chunk
      end
    end

    def replace_keys(row)
      return row unless options.mapping
      row.map do |key, value|
        [options.mapping[key], value] if options.mapping.has_key?(key)
      end.compact.to_h
    end
  end
end
