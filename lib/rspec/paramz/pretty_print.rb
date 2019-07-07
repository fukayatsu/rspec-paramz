module RSpec
  module Paramz
    module PrettyPrint
      def self.inspect(value, raw_value = true)
        case value
        when Hash
          subject(value)
        when Proc
          to_source(value)
        else
          raw_value ? value : value.inspect
        end
      end

      def self.subject(value)
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

      def self.to_source(value)
        return value if value.is_a?(NamedProc) || !value.is_a?(Proc)

        node = RubyVM::AbstractSyntaxTree.of(value)
        return value if node.nil?

        path = value.source_location.first
        lines = File.readlines(path)
        source_lines = lines[(node.first_lineno - 1)..(node.last_lineno - 1)]
        source_lines[-1] = source_lines[-1][0..(node.last_column - 1)]
        source_lines[0]  = source_lines[0][node.first_column..]
        source_lines.map(&:strip).join("\n")
      end
    end
  end
end
