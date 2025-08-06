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
      ) do
        it "do additions" do
          expect(a + b).to eq answer
        end
      end
    end
  end
end
# rubocop:enable Layout/SpaceInsideArrayLiteralBrackets
