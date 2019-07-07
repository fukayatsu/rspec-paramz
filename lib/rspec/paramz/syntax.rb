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
    module Syntax
      refine Symbol do
        def &
          _self = self
          NamedProc.new(self) { __send__(_self) }
        end
      end
    end
  end
end
