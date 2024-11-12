# frozen_string_literal: true

module RailsEdgeTest
  module Printers
    class Silent
      def begin_suite; end

      def end_suite; end

      def begin_controller(_controller); end

      def end_controller; end

      def begin_action(_action); end

      def end_action; end

      def begin_edge(_edge); end

      def end_edge; end
    end
  end
end
