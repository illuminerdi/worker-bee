#!/usr/bin/env ruby -w

require 'pp'

module Kernel
  alias :old_puts :puts
  def puts(string)
    string
  end
end

class WorkerBee
  VERSION = '0.0.2'

  class << self; attr_accessor :tasks, :already_ran; end
  
  def initialize
  end
  
  def self.recipe(&block)
    @tasks = []
    @already_ran = []
    instance_eval(&block)
  end
  
  def self.run(symbol)
    output = self.send(:"#{symbol}")
    output.each do |line| old_puts line; end
  end
  
  def self.work(*symbols, &block)
    symbol = symbols.shift
    tasks << symbol
    completed_msg = (yield if block_given?) || ""
    dep_calls = ""
    symbols.each {|sym|
      dep_calls += %{msg = self.#{sym}(msg, indent+2)\n}
    }
    new_def = %{
      def self.#{symbol}(msg=[], indent=0)
        indenting = ""
        indent.times do indenting = "\#\{indenting\} "; end
        if already_ran.include?("#{symbol}")
          msg << "\#\{indenting\}not running #{symbol} - already met dependency"
        else
          msg << "\#\{indenting\}Running #{symbol}"
          #{dep_calls}
          already_ran << "#{symbol}" unless already_ran.include?("#{symbol}")
          msg << "#{completed_msg}"
        end
      end
    }
    self.class_eval new_def
  end
end