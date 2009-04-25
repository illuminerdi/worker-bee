#!/usr/bin/env ruby -w

class WorkerBee
  VERSION = '1.0.0'

  class << self; attr_accessor :tasks; end
  
  def initialize
  end
  
  def self.recipe(&block)
    @tasks = []
    instance_eval(&block)
  end
  
  def self.work(*symbols, &block)
    symbol = symbols.shift
    tasks << symbol
    foo = block.class || nil

    self.class_eval %{
      def self.#{symbol}(*deps)
        puts "Running #{symbol}"
        completed_msg = ""
      end
    }
  end
end