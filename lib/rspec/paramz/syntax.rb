module RSpec
  module Paramz
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
