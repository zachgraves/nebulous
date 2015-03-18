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
      result = []

      headers = Row.map(readline, options) if options[:headers]
      chunk = Chunk.new(chunk_options)

      while !file.eof?
        row = Row.parse(read_complete_line, options)
        chunk << headers.values.zip(row).to_h

        if options.chunk && chunk_full?(chunk)
          result << yield_chunk(chunk, &block)
          chunk = Chunk.new(chunk_options)
        end
      end

      options.chunk ? result : chunk
    ensure
      file.rewind
    end

    def delimiters
      @delimiters ||= DelimiterDetector.new(file.path).detect
    end

    private

    def yield_chunk(chunk, &_block)
      yield chunk if block_given?
      chunk
    end

    def chunk_full?(chunk)
      chunk.full? || file.eof?
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
  end
end
