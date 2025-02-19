module RSpec
  module Paramz
    module PrettyPrint
      class << self
        def inspect(value, raw_value = true)
          case value
          when Hash
            subject(value)
          when Proc
            to_source(value)
          else
            raw_value ? value : value.inspect
          end
        end

        def subject(value)
          return value if value.keys != [:subject]

          _subject = value.values.first
          case _subject
          when Proc
            "subject #{to_source(_subject)}"
          when Hash
            subject_name  = _subject.keys.first
            subject_value = _subject.values.first

            case subject_value
            when Proc
              "subject(:#{subject_name}) #{to_source(subject_value)}"
            else
              "subject { #{subject_value} }"
            end
          else
            value
          end
        end

        def to_source(value)
          return value if value.is_a?(NamedProc) || !value.is_a?(Proc)

          code_location = fetch_code_location(value)
          return value if code_location.nil?

          path = value.source_location.first
          lines = File.readlines(path)

          source_lines = lines[(code_location[0] - 1)..(code_location[2] - 1)]
          source_lines[-1] = source_lines[-1][0..(code_location[3] - 1)]
          source_lines[0]  = source_lines[0][code_location[1]..]
          source_lines.map(&:strip).join("\n")
        end

        private

        def fetch_code_location(value)
          # if RubyVM::InstructionSequence.compile("").to_a[4][:parser] == :prism
            iseq = RubyVM::InstructionSequence.of(value)
            iseq.to_a[4][:code_location]
          # else
          #   node = RubyVM::AbstractSyntaxTree.of(value)
          #   return nil if node.nil?
          #   [node.first_lineno, node.first_column, node.last_lineno, node.last_column]
          # end
        end
      end
    end
  end
end
