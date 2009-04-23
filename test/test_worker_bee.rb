#!/usr/bin/env ruby -w

require 'test/unit'
require 'worker_bee'




class TestWorkerBee < Test::Unit::TestCase
  
  def setup
    WorkerBee.recipe do
      work :sammich, :meat, :bread do
        puts "** sammich!"
      end

      work :meat, :clean do
        puts "** meat"
      end

      work :bread, :clean do
        puts "** bread"
      end

      work :clean do
        puts "** cleaning!"
      end
    end
  end
  
  def test_has_recipe
    assert WorkerBee.respond_to?(:recipe)
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
  
  def test_recipe_registers_new_work_with_no_dependencies_and_it_returns_the_block
    WorkerBee.recipe do
      work :test do
        puts "** test"
      end
      assert_equal "** test", WorkerBee.test
    end
  end
end