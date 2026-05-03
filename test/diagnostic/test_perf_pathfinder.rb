# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/dnd5e/core/tactical_grid'
require_relative '../../lib/dnd5e/core/helpers/pathfinder'

class TestPerfPathfinder < Minitest::Test
  def setup
    @grid = Dnd5e::Core::TacticalGrid.new
    @pathfinder = Dnd5e::Core::Helpers::Pathfinder.new(@grid)
  end

  def test_find_path_100ft
    start = Dnd5e::Core::Point2D.new(0, 0)
    goal = Dnd5e::Core::Point2D.new(100, 100)

    start_time = Time.now
    100.times { @pathfinder.find_path(start, goal) }
    duration = Time.now - start_time
    puts "\nfind_path (100x, 100ft dist): #{duration}s"
  end

  def test_find_path_blocked
    start = Dnd5e::Core::Point2D.new(0, 0)
    goal = Dnd5e::Core::Point2D.new(50, 50)

    # Block goal
    @grid.instance_variable_get(:@occupants)[goal] = [Struct.new(:team).new(:enemy)]

    start_time = Time.now
    100.times { @pathfinder.find_path(start, goal) }
    duration = Time.now - start_time
    puts "find_path (100x, 50ft BLOCKED): #{duration}s"
  end
end
