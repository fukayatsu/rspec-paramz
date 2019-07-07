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

      #=>
      # [a = 1 | b = 2 | answer = 3]
      #   should do additions
      # [a = 3 | b = 8 | answer = 11]
      #   should do additions
      # [a = 5 | b = -8 | answer = -3]
      #   should do additions
    end

    context 'format 2' do
      paramz(
        [:a, :b, subject: -> { a + b }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      )

      #=>
      # [a = 1 | b = 2 | subject { a + b } = 3]
      #   should == 3
      # [a = 3 | b = 8 | subject { a + b } = 11]
      #   should == 11
      # [a = 5 | b = -8 | subject { a + b } = -3]
      #   should == -3
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

      #=>
      # [a = 1 | b = 2 | subject { a + b } = 3]
      #   should do additions
      # [a = 3 | b = 8 | subject { a + b } = 11]
      #   should do additions
      # [a = 5 | b = -8 | subject { a + b } = -3]
      #   should do additions
    end

    context 'format 3' do
      paramz(
        [:a, :b, subject: { answer: -> { a + b } }],
        1,   2,  3,
        3,   8,  11,
        5,   -8, -3,
      )

      #=>
      # [a = 1 | b = 2 | subject(:answer) { a + b } = 3]
      #   should == 3
      # [a = 3 | b = 8 | subject(:answer) { a + b } = 11]
      #   should == 11
      # [a = 5 | b = -8 | subject(:answer) { a + b } = -3]
      #   should == -3
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

      #=>
      # [a = 1 | b = 2 | subject(:answer) { a + b } = 3]
      #   should do additions
      #   should do additions
      # [a = 3 | b = 8 | subject(:answer) { a + b } = 11]
      #   should do additions
      #   should do additions
      # [a = 5 | b = -8 | subject(:answer) { a + b } = -3]
      #   should do additions
      #   should do additions
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

        #=>
        # [a = { one } | b = 0 | answer = 1]
        #   should do additions
        # [a = { one } | b = { one } | answer = { 2 }]
        #   should do additions
        # [a = { one } | b = { two } | answer = { three }]
        #   should do additions
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

        #=>
        # [a = { one } | b = 0 | answer = 1]
        #   should do additions
        # [a = { one } | b = { one } | answer = { 2 }]
        #   should do additions
        # [a = { one } | b = { two } | answer = { three }]
        #   should do additions
      end
    end

    context 'nil or empty' do
      paramz(
        [:a,   :b,  :answer],
        "foo", nil,   "foo",
        "",    nil,   "",
        nil,   "bar", nil
      ) do
        it 'should do additions' do
          expect(a&.to_s).to eq answer
        end
      end

      #=>
      # [a = "foo" | b = nil | answer = "foo"]
      #   should do additions
      # [a = "" | b = nil | answer = ""]
      #   should do additions
      # [a = nil | b = "bar" | answer = nil]
      #   should do additions
    end
  end
end
