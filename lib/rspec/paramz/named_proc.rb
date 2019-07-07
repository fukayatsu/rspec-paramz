module RSpec
  module Paramz
    class NamedProc < Proc
      def initialize(name, &block)
        @name = name
        super(&block)
      end

      def to_s
        "{ #{@name} }"
      end

      alias_method :inspect, :to_s
    end
  end
end
