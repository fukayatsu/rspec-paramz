require "rspec/paramz/version"
require "rspec/paramz/syntax"
require "rspec/paramz/named_proc"
require "rspec/paramz/pretty_print"

module RSpec
  module Paramz
    module ExampleGroupMethods
      def paramz(*args, &block)
        labels = args.first

        if !block_given? && !labels.any? { |label| subject_label?(label) }
          raise ArgumentError, "No block or subject given to paramz."
        end

        args[1..-1].each_slice(labels.length).with_index do |arg, index|
          pairs = [labels, arg].transpose.to_h

          context_name = '[' + pairs.map { |k, v| "#{RSpec::Paramz::PrettyPrint.inspect(k)} = #{RSpec::Paramz::PrettyPrint.inspect(v, false)}" }.join(' | ') + ']'

          context context_name do
            pairs.each do |label, val|
              if subject_label?(label)
                if label == :subject
                  it { should == val }
                  next
                end

                _subject, _subject_name = parse_subject(label)

                module_exec { _subject.is_a?(Proc) ? subject(_subject_name, &_subject) : subject(_subject_name) { _subject }  }
                it { should == val } unless block_given?
              else
                module_exec { val.is_a?(Proc) ? let(label, &val) : let(label) { val } }
              end
            end

            module_eval(&block) if block_given?

            after(:each) do |example|
              if example.exception
                index_info = arg.map { |v| RSpec::Paramz::PrettyPrint.inspect(v, false) }.join(', ')
                example.exception.backtrace.push("failed paramz index is:#{index + 1}:[#{index_info}]")
              end
            end
          end
        end
      end

      private

      def subject_label?(label)
        return true if label == :subject
        label.is_a?(Hash) && label.keys == [:subject]
      end

      def parse_subject(label)
        _subject = label[:subject]

        _subject_name = nil
        if _subject.is_a?(Hash)
          _subject_name = _subject.keys.first
          _subject      = _subject.values.first
        end

        [_subject, _subject_name]
      end
    end
  end

  module Core
    class ExampleGroup
      extend ::RSpec::Paramz::ExampleGroupMethods
    end
  end
end
