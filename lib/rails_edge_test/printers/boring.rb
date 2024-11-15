# frozen_string_literal: true

module RailsEdgeTest
  module Printers
    class Boring
      def initialize
        @count = 0
      end

      def begin_suite
        puts ''
      end

      def end_suite
        puts "\n#{@count} edge specs executed."
      end

      def begin_controller(_controller)
        print '.'
      end

      def end_controller; end

      def begin_action(_action)
        print '.'
      end

      def end_action; end

      def begin_edge(_edge)
        print '.'
      end

      def end_edge
        @count += 1
      end
    end
  end
end
