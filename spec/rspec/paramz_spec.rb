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

    describe "true / false" do
      paramz(
        -> { [:a,   :b,    :answer] },
        -> { [true, false, false] },
      ) do
        it "does boolean logic" do
          expect(a & b).to eq answer
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
