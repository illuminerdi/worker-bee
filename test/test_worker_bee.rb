#!/usr/bin/env ruby -w

require 'test/unit'
require 'worker_bee'




class TestWorkerBee < Test::Unit::TestCase
  
  def setup
    load 'sammich.wb'
  end
  
  def test_has_recipe
    assert WorkerBee.respond_to?(:recipe)
  end
  
  def test_recipe_with_no_work_has_no_tasks
    WorkerBee.recipe do
    end
    
    assert WorkerBee.tasks.empty?
  end
  
  def test_recipe_with_one_work_has_one_task
    WorkerBee.recipe do
      work :test
    end
    
    assert_equal 1, WorkerBee.tasks.size
    assert_equal "test", WorkerBee.tasks.first.to_s
  end
  
  def test_has_work
    assert WorkerBee.respond_to?(:work)
  end
  
  def test_recipe_registers_new_work
    WorkerBee.recipe do
      work :test
    end
    assert WorkerBee.respond_to?(:test)
  end
end