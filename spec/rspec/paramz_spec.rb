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

    describe "foo" do
      let(:foo) { "かきくけこ" }
      let(:bar) { "さしすせそ" }
      paramz(
        -> { [:text1, :text2, :text3, :text4] },
        -> { [ "あいう\nえお", foo, nil, bar ] },
      ) do
        it "has the correct values" do
          expect(text1).to eq "あいう\nえお"
          expect(text2).to eq "かきくけこ"
          expect(text3).to be_nil
          expect(text4).to eq "さしすせそ"
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
