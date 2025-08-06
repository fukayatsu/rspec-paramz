require "rspec/paramz/version"
module RSpec
  module Paramz
    module ExampleGroupMethods
      def paramz(*args, &block)
        unless block_given?
          raise ArgumentError, "No block or subject given to paramz."
        end

        labels = args.first
        labels = labels.call if labels.respond_to?(:call)
        args[1..].each do |arg|
          location = arg.source_location
          source = File.read(location.first).each_line.to_a[location[1] - 1].strip.delete_suffix(",")
          context_name = source

          context context_name do
            let(:__paramz_values__, &arg)
            labels.each.with_index do |label, index|
              let(label) { __paramz_values__[index] }
            end

            module_exec(&block)

            after(:each) do |example|
              if example.exception
                location = arg.source_location
                example.exception.backtrace.push("failed paramz: #{location.first}:#{location.last}")
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
