module Nebulous
  class Parser
    include Nebulous::Input::Reader
    include Nebulous::Input::Parsing
    include Nebulous::Input::Delimiters

    DEFAULT_OPTIONS = {
      col_sep: nil,
      row_sep: nil,
      quote_char: '"',
      comment_exp: /^#/,
      chunk: false,
      headers: true,
      start: nil,
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

    def headers
      @file.rewind
      raw_headers
    end

    def process(&block)
      @index = 0
      header_hash if options[:headers]
      iterate(&block)
    ensure
      reset
      file.rewind
    end

    private

    def reset
      @index = 0
      @header_hash = nil
      @chunk = nil
    end
  end
end
