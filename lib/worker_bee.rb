#!/usr/bin/env ruby -w

module WorkerBee
  VERSION = '0.0.3'
  
  class Work
    attr_accessor :block, :dependents, :already_done
    
    def initialize dependents, block
      @block = block
      @dependents = dependents
      @already_done = false
    end
    
    def run
      @already_done = true
      @block.call
    end
  end
  
  @tasks = {}
  def self.tasks; @tasks; end
  
  def self.recipe(&block)
    raise(ArgumentError, "WorkerBee#recipe expects a block") unless block_given?
    @tasks = {}
    module_eval(&block)
  end
  
  def self.work(*symbols, &block)
    raise(ArgumentError, "WorkerBee#work expects a block") unless block_given?
    task_name = symbols.shift
    @tasks[task_name] = WorkerBee::Work.new symbols, block
  end
  
  def self.run(task, indent=0)
    this_task = task.to_sym
      if @tasks[this_task].already_done
        puts "#{'  ' * indent}not running #{this_task} - already met dependency"
      else
        puts "#{'  ' * indent}Running #{task}"
        @tasks[this_task].dependents.each do |dependent|
          run(dependent, indent+1)
        end
        @tasks[this_task].run        
      end
  end
end
