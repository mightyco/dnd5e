# frozen_string_literal: true

require 'test_helper'
require 'dnd5e/core/rule_repository'

class TestRuleRepository < Minitest::Test
  def setup
    # Reset singleton and mock file ops
    @repo = Dnd5e::Core::RuleRepository.instance
    # We can't easily reset Singleton state without metaprogramming,
    # so we rely on dependency injection or file mocking in a real scenario.
    # For now, we'll verify it behaves safely with missing files.
  end

  def test_singleton_access
    assert_same @repo, Dnd5e::Core::RuleRepository.instance
  end

  def test_loading_missing_file_is_safe
    # Temporarily rename cache if it exists
    cache_path = Dnd5e::Core::RuleRepository::CACHE_FILE
    FileUtils.mv(cache_path, "#{cache_path}.bak") if File.exist?(cache_path)

    begin
      @repo.reload!

      refute_predicate @repo, :loaded?
      assert_empty @repo.spells
    ensure
      FileUtils.mv("#{cache_path}.bak", cache_path) if File.exist?("#{cache_path}.bak")
    end
  end

  def test_loading_valid_data
    # Create a dummy cache file
    data = {
      spells: [{ name: 'Test Spell', level: '1st', school: 'Evo', casting_time: '1a', range: '60ft', components: 'V',
                 duration: 'Inst', description: 'Boom' }]
    }
    File.write(Dnd5e::Core::RuleRepository::CACHE_FILE, JSON.dump(data))

    @repo.reload!

    assert_predicate @repo, :loaded?
    assert_equal 1, @repo.spells.count
    assert_kind_of Dnd5e::Core::Spell, @repo.spells['Test Spell']
  end
end
