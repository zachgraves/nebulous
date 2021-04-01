require 'csv'
require 'ostruct'
require 'terrapin'
require 'active_support/all'
require 'nebulous/version'
require 'nebulous/delimiter_detector'
require 'nebulous/row'
require 'nebulous/chunk'
require 'nebulous/input'
require 'nebulous/input/reader'
require 'nebulous/input/parsing'
require 'nebulous/input/delimiters'
require 'nebulous/parser'

module Nebulous
  def self.process(file, *args, &block)
    Parser.new(file, *args).process(&block)
  end
end
