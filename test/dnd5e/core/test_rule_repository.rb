# frozen_string_literal: true

require 'test_helper'
require 'dnd5e/core/rule_repository'

class TestRuleRepository < Minitest::Test
  def setup
    @repo = Dnd5e::Core::RuleRepository.instance
    @cache_path = Dnd5e::Core::RuleRepository::CACHE_FILE
    @backup_path = "#{@cache_path}.bak"
    FileUtils.mv(@cache_path, @backup_path) if File.exist?(@cache_path)
  end

  def teardown
    FileUtils.rm_f(@cache_path)
    FileUtils.mv(@backup_path, @cache_path) if File.exist?(@backup_path)
    @repo.reload!
  end

  def test_singleton_access
    assert_same @repo, Dnd5e::Core::RuleRepository.instance
  end

  def test_loading_missing_file_is_safe
    @repo.reload! # Now file is missing because of setup mv

    refute_predicate @repo, :loaded?
    assert_empty @repo.spells
  end

  def test_loading_valid_spells
    data = {
      spells: [{ name: 'Test Spell', level: '1st', school: 'Evo', casting_time: '1a', range: '60ft', components: 'V',
                 duration: 'Inst', description: 'Boom' }],
      class_tables: {}
    }
    File.write(@cache_path, JSON.dump(data))
    @repo.reload!

    assert_predicate @repo, :loaded?
    assert_equal 1, @repo.spells.count
  end

  def test_loading_valid_classes
    data = {
      spells: [],
      class_tables: { Fighter: [{ level: 1, proficiency_bonus: '+2', features: 'Second Wind' }] }
    }
    File.write(@cache_path, JSON.dump(data))
    @repo.reload!

    assert_equal 1, @repo.class_tables.count
    assert_equal 'Second Wind', @repo.class_tables[:Fighter][0][:features]
  end
end
