#!/usr/bin/env ruby -w

require 'test/unit'
require 'worker_bee'
require 'stringio'

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    $stdout = STDOUT
    return out
  end
end

class TestWorkerBee < Test::Unit::TestCase
  
  def setup
    load 'sammich.wb'
  end
  
  def test_has_recipe
    assert WorkerBee.respond_to?(:recipe)
  end

  def test_has_work
    assert WorkerBee.respond_to?(:work)
  end
  
  def test_recipe_with_no_work_throws_error
    assert_raise ArgumentError do
      WorkerBee.recipe
    end
  end
  
  def test_recipe_with_work_with_no_block_throws_error
    assert_raise ArgumentError do
      WorkerBee.recipe do
        work :test
      end
    end
  end
    
  def test_recipe_with_one_work_has_one_task
    WorkerBee.recipe do
      work :test do
        puts "test work!"
      end
    end
    
    assert_equal 1, WorkerBee.tasks.size
    assert_equal "test", WorkerBee.tasks.keys.first.to_s
  end
  
  def test_recipe_registers_new_work_and_it_runs_properly
    WorkerBee.recipe do
      work :test do
        puts "** testing!"
      end
    end
    
    actual = capture_stdout do
      WorkerBee.run(:test)
    end
    
    assert_equal "Running test\n** testing!", actual.string.chomp
  end
  
  def test_running_a_work_task_that_does_not_exist_throws_exception
    assert_raise(ArgumentError) do
      WorkerBee.run(:foo)
    end
  end
  
  def test_recipe_with_two_works_one_dependent_on_the_other
    WorkerBee.recipe do
      work :first_test, :second_test do
        puts "** first test should be last!"
      end
      work :second_test do
        puts "** second test should be first!"
      end
    end
    
    actual = capture_stdout do
      WorkerBee.run(:first_test)
    end
    
    expected = [
      "Running first_test", 
      "  Running second_test", 
      "** second test should be first!", 
      "** first test should be last!"]
    assert_equal expected.join("\n"), actual.string.chomp
  end
  
  def test_recipe_with_work_dependent_twice_only_runs_once
    actual = capture_stdout do
      WorkerBee.run(:sammich)
    end
    assert actual.string.include?("    not running clean - already met dependency")
  end
end
