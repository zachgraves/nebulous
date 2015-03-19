module Nebulous
  class Chunk < Array
    attr_reader :options

    def initialize(*args)
      @options = args.extract_options!
      super
    end

    def full?
      options.has_key?(:size) && options[:size] == size
    end
  end
end
