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
  
  def test_has_work
    assert WorkerBee.respond_to?(:work)
  end
    
  def test_recipe_with_one_work_has_one_task
    WorkerBee.recipe do
      work :test
    end
    
    assert_equal 1, WorkerBee.tasks.size
    assert_equal "test", WorkerBee.tasks.first.to_s
  end

  def test_recipe_registers_new_work
    WorkerBee.recipe do
      work :test
    end
    assert WorkerBee.respond_to?(:test)
  end
  
  def test_recipe_registers_new_work_and_it_lets_us_know_its_running
    WorkerBee.recipe do
      work :test do
        puts "** testing!"
      end
    end
    
    assert_equal ["Running test","** testing!"], WorkerBee.test
  end
  
  def test_recipe_with_two_works_one_dependent_on_the_other
    WorkerBee.recipe do
      work :first_test, :second_test do
        puts "** testing last!"
      end
      
      work :second_test do
        puts "** testing first!"
      end
    end
    expected = ["Running first_test", "  Running second_test", "** testing first!", "** testing last!"]
    assert_equal expected, WorkerBee.first_test
  end
  
  def test_recipe_with_work_dependent_twice_only_runs_once
    actual = WorkerBee.sammich
    assert actual.include?("    not running clean - already met dependency")
  end
end