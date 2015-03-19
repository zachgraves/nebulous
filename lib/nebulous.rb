require 'csv'
require 'ostruct'
require 'cocaine'
require 'active_support/all'
require 'nebulous/version'
require 'nebulous/parser'
require 'nebulous/row'
require 'nebulous/chunk'
require 'nebulous/delimiter_detector'

module Nebulous
  def self.process(file, *args, &block)
    Parser.new(file, *args).process(&block)
  end
end
