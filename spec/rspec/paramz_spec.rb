# rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
RSpec.describe RSpec::Paramz do
  describe "#paramz" do
    describe "additions" do
      let(:one) { 1 }
      let(:two) { 2 }
      let(:three) { 3 }
      paramz(
        -> { [:a,  :b,   :answer] },
        -> { [one, two,  three  ] },
        -> { [3,   8,    11     ] },
        -> { [5,   -8,   -3     ] },
        -> { ["a", "b",  "ab"   ] },
      ) do
        it "do additions" do
          expect(a + b).to eq answer
        end
      end
    end

    describe "types" do
      let(:data) { Data.define(:foo).new(foo: :bar) }
      paramz(
        -> { [:actual,       :expected     ] },
        -> { [true,          true          ] },
        -> { [false,         false         ] },
        -> { [:foo,          :foo          ] },
        -> { ["bar",         "bar"         ] },
        -> { [%(bar),        "bar"         ] },
        -> { [%i[baz],       [:baz]        ] },
        -> { [%w[qux],       ["qux"]       ] },
        -> { [nil,           nil           ] },
        -> { [[1],           [1]           ] },
        -> { [{ foo: :bar }, { foo: :bar } ] },
        -> { [data.foo,      :bar          ] },
      ) do
        it "equals" do
          expect(actual).to eq(expected)
        end
      end
    end

    describe "symbol to_s" do
      paramz(
        -> { [:before, :after] },
        -> { [:foo,    "foo" ] },
      ) do
        it "returns the correct string representation" do
          expect(before.to_s).to eq after
        end
      end
    end
  end
end
# rubocop:enable Layout/SpaceInsideArrayLiteralBrackets
