# frozen_string_literal: true

module Dnd5e
  module Core
    module Publisher
      def add_observer(observer)
        @observers ||= []
        @observers << observer
      end

      def remove_observer(observer)
        @observers ||= []
        @observers.delete(observer)
      end

      def notify_observers(event, data = {})
        @observers ||= []
        @observers.each do |observer|
          observer.update(event, data)
        end
      end
    end
  end
end
