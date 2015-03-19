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

    def initialize(file, *args)
      opts = args.extract_options!

      @options = OpenStruct.new DEFAULT_OPTIONS.merge(opts)
      @file = read_input(file)

      merge_delimiters
    end

    def process(&block)
      @headers ||= read_headers
      iterate(&block)
    ensure
      @headers = nil
      @chunk = nil
      file.rewind
    end

    def delimiters
      @delimiters ||= DelimiterDetector.new(file.path).detect
    end

    def chunk
      @chunk ||= Chunk.new chunk_options
    end

    private

    def reset
      @chunk = nil
    end

    def read_headers
      Row.headers(readline, options) if options[:headers]
    end

    def iterate(&block)
      while !file.eof?
        chunk << replace_keys(parse_row.merge(@headers))
        yield_chunk(chunk, &block) if options.chunk && block_given?
      end
      @chunk
    end

    def parse_row
      Row.parse(read_complete_line, options)
    end

    def yield_chunk(chunk, &_block)
      if chunk.full? || file.eof?
        yield chunk.map(&:to_a)
        @chunk = nil
      end
    end

    def chunk?(chunk)
      options.chunk && (chunk.full? || file.eof?)
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
