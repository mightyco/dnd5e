# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/publisher'

module Dnd5e
  module Core
    class TestPublisher < Minitest::Test
      class TestSubject
        include Publisher
      end

      class TestObserver
        attr_reader :events

        def initialize
          @events = []
        end

        def update(event, data)
          @events << { event: event, data: data }
        end
      end

      def setup
        @subject = TestSubject.new
        @observer = TestObserver.new
      end

      def test_add_observer
        @subject.add_observer(@observer)
        @subject.notify_observers(:test_event, { foo: 'bar' })
        assert_equal 1, @observer.events.length
        assert_equal :test_event, @observer.events.first[:event]
        assert_equal 'bar', @observer.events.first[:data][:foo]
      end

      def test_remove_observer
        @subject.add_observer(@observer)
        @subject.remove_observer(@observer)
        @subject.notify_observers(:test_event)
        assert_empty @observer.events
      end

      def test_multiple_observers
        observer2 = TestObserver.new
        @subject.add_observer(@observer)
        @subject.add_observer(observer2)
        @subject.notify_observers(:broadcast)

        assert_equal 1, @observer.events.length
        assert_equal 1, observer2.events.length
      end
    end
  end
end
