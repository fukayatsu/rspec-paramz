RSpec.describe RSpec::Paramz do
  describe '#paramz' do
    context 'format 1' do
      paramz(
        [:a, :b, :answer],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      ) do
        it 'should do additions' do
          expect(a + b).to eq answer
        end
      end
    end

    context 'format 2' do
      paramz(
        [:a, :b, subject: -> { a + b }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      )
    end

    context 'format 2-a' do
      paramz(
        [:a, :b, subject: -> { a + b }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      ) do
        it 'should do additions' do
          expect(subject).to eq(a + b)
        end
      end
    end

    context 'format 3' do
      paramz(
        [:a, :b, subject: { answer: -> { a + b } }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      )
    end

    context 'format 3-b' do
      paramz(
        [:a, :b, subject: { answer: -> { a + b } }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      ) do
        it 'should do additions' do
          expect(subject).to eq(a + b)
        end

        it 'should do additions' do
          expect(answer).to eq(a + b)
        end
      end
    end

    context 'rspec-let' do
      let(:one)   { 1 }
      let(:two)   { one * 2 }
      let(:three) { one * 3 }

      context 'default' do
        paramz(
          [:a,       :b,          :answer],
          -> { one }, 0,          1,
          -> { one }, -> { one }, -> { 2 },
          -> { one }, -> { two }, -> { three },
        ) do
          it 'should do additions' do
            expect(a + b).to eq answer
          end
        end
      end

      context 'using RSpec::Paramz::Syntax' do
        using RSpec::Paramz::Syntax
        paramz(
          [:a,    :b,     :answer],
          :one.&, 0,      1,
          :one.&, :one.&, -> { 2 },
          :one.&, :two.&, :three.&,
        ) do
          it 'should do additions' do
            expect(a + b).to eq answer
          end
        end
      end
    end
  end
end
