# RSpec::Paramz [![Gem Version](https://badge.fury.io/rb/rspec-paramz.svg)](https://badge.fury.io/rb/rspec-paramz) [![Build Status](https://travis-ci.org/fukayatsu/rspec-paramz.svg?branch=master)](https://travis-ci.org/fukayatsu/rspec-paramz)

Simple Parameterized Test for RSpec.

Inspired by [tomykaira/rspec-parameterized](https://github.com/tomykaira/rspec-parameterized).

## Requirements

- Ruby 3.1 or later

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-paramz'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-paramz

## Usage

See [paramz_spec.rb](https://github.com/fukayatsu/rspec-paramz/blob/master/spec/rspec/paramz_spec.rb) for example.

```ruby
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

    context 'format 4' do
      subject { a + b }

      paramz(
        [:a, :b, :subject],
        1,   2,   3,
        0,   0,   0,
        -1,  -2,  -3,
      )

      #=>
      # [a = 1 | b = 2 | subject = 3]
      #   should == 3
      # [a = 0 | b = 0 | subject = 0]
      #   should == 0
      # [a = -1 | b = -2 | subject = -3]
      #   should == -3
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

      context 'default 2' do
        subject { a + b }
        paramz(
          [:a,       :b,          :subject],
          -> { one }, 0,          1,
          -> { one }, -> { one }, -> { 2 },
          -> { one }, -> { two }, -> { three },
        )

        #=>
        # [a = { one } | b = 0 | subject = 1]
        #   should == 1
        # [a = { one } | b = { one } | subject = { 2 }]
        #   should == 2
        # [a = { one } | b = { two } | subject = { three }]
        #   should == 3
      end

      context 'default 3' do
        paramz(
          [:a,       :b,          subject: -> { a + b }],
          -> { one }, 0,          1,
          -> { one }, -> { one }, -> { 2 },
          -> { one }, -> { two }, -> { three },
        )

        #=>
        # [a = { one } | b = 0 | subject { a + b } = 1]
        #   should == 1
        # [a = { one } | b = { one } | subject { a + b } = { 2 }]
        #   should == 2
        # [a = { one } | b = { two } | subject { a + b } = { three }]
        #   should == 3
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fukayatsu/rspec-paramz. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RSpec::Paramz project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fukayatsu/rspec-paramz/blob/master/CODE_OF_CONDUCT.md).
