# frozen_string_literal: true

require 'json'
require 'fileutils'

module Dnd5e
  module Tools
    # Audits implemented features against reference rule texts.
    class FeatureAudit
      REFERENCES = {
        phb: 'rules_reference/dnd_players_handbook_compressed.txt',
        dmg: 'rules_reference/dnd_dungeon_masters_guide_compressed.txt',
        mm: 'rules_reference/monster_manual_compressed.txt',
        srd: 'srd_reference/SRD_CC_v5.2.1.txt'
      }.freeze

      FEATURES = {
        'Precision Attack' => {
          keywords: ['expend one Superiority Die', 'add it to the attack roll'],
          source: :phb
        },
        'Trip Attack' => {
          keywords: ['Large or smaller', 'Strength saving throw', 'Prone condition'],
          source: :phb
        },
        'Pushing Attack' => {
          keywords: ['Large or smaller', '15 feet away', 'Strength saving throw'],
          source: :phb
        },
        'Tactical Shift' => {
          keywords: ['Second Wind', 'move up to half your speed'],
          source: :phb
        },
        'Improved Critical' => {
          keywords: ['19 or 20'],
          source: :phb
        },
        'Topple' => {
          keywords: ['Dexterity saving throw', 'Prone condition'],
          source: :phb
        },
        'Vex' => {
          keywords: ['Advantage', 'next Attack roll'],
          source: :phb
        },
        'Graze' => {
          keywords: ['miss with an Attack roll', 'Ability modiﬁer'],
          source: :phb
        }
      }.freeze

      def run
        puts "Starting Feature Audit against Reference Texts...\n\n"
        results = FEATURES.map { |name, cfg| audit_feature(name, cfg) }

        summary(results)
      end

      def audit_feature(name, cfg)
        path = REFERENCES[cfg[:source]]
        return { name: name, status: :skipped, message: "Missing: #{path}" } unless File.exist?(path)

        missing = find_missing_keywords(path, cfg[:keywords])
        handle_audit_result(name, cfg, missing)
      end

      private

      def find_missing_keywords(path, keywords)
        content = File.read(path).downcase
        keywords.reject { |k| content.include?(k.downcase) }
      end

      def handle_audit_result(name, cfg, missing)
        if missing.empty?
          puts "\e[32m[PASS]\e[0m #{name}: All keywords found in #{cfg[:source].upcase}"
          { name: name, status: :pass }
        elsif cfg[:source] != :srd
          audit_feature(name, cfg.merge(source: :srd))
        else
          puts "\e[31m[FAIL]\e[0m #{name}: Missing keywords: #{missing.join(', ')}"
          { name: name, status: :fail, missing: missing }
        end
      end

      def summary(results)
        passed = results.count { |r| r[:status] == :pass }
        failed = results.count { |r| r[:status] == :fail }
        skipped = results.count { |r| r[:status] == :skipped }

        puts "\nAudit Summary:"
        puts "  Passed: #{passed}, Failed: #{failed}, Skipped: #{skipped}"

        exit 1 if failed.positive?
      end
    end
  end
end

Dnd5e::Tools::FeatureAudit.new.run if __FILE__ == $PROGRAM_NAME
