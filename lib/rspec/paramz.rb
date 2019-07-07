require "rspec/paramz/version"
require "rspec/paramz/syntax"

module RSpec
  module Paramz
    module ExampleGroupMethods
      def paramz(*args, &block)
        labels = args.first

        if !block_given? && labels.all? { |label| !label.is_a?(Hash) || label.keys != [:subject] }
          raise ArgumentError, "No block or subject given to paramz."
        end

        args[1..-1].each_slice(labels.length).with_index do |arg, index|
          pairs = [labels, arg].transpose.to_h

          context_name = '[' + pairs.map { |k, v| "#{RSpec::Paramz.pretty_print(k)} = #{RSpec::Paramz.pretty_print(v)}" }.join(' | ') + ']'

          context context_name do
            pairs.each do |name, val|
              if name.is_a?(Hash)
                raise "error" if name.keys != [:subject]
                _subject = name[:subject]

                _subject_name = nil
                if _subject.is_a?(Hash)
                  _subject_name = _subject.keys.first
                  _subject      = _subject.values.first
                end

                module_exec { _subject.is_a?(Proc) ? subject(_subject_name, &_subject) : subject(_subject_name) { _subject }  }
                unless block_given?
                  it { should == val }
                end
              else
                module_exec { val.is_a?(Proc) ? let(name, &val) : let(name) { val } }
              end
            end

            module_eval(&block) if block_given?

            after(:each) do |example|
              if example.exception
                index_info = arg.map { |v| RSpec::Paramz.pretty_print(v) }.join(', ')
                example.exception.backtrace.push("failed paramz index is:#{index + 1}:[#{index_info}]")
              end
            end
          end
        end
      end
    end

    # TODO: Extract to other file
    def self.pretty_print(value)
      case value
      when Hash
        pretty_subject(value)
      when NamedProc
        value
      when Proc
        proc_source(value)
      else
        value
      end
    end

    def self.proc_source(value)
      node = RubyVM::AbstractSyntaxTree.of(value)
      return value if node.nil?

      path = value.source_location.first
      lines = File.readlines(path)
      source_lines = lines[(node.first_lineno - 1)..(node.last_lineno - 1)]
      source_lines[-1] = source_lines[-1][0..(node.last_column - 1)]
      source_lines[0]  = source_lines[0][node.first_column..]
      source_lines.map(&:strip).join("\n")
    end

    def self.pretty_subject(value)
      return value if value.keys != [:subject]

      _subject = value.values.first
      case _subject
      when NamedProc
        "subject #{_subject}"
      when Proc
        "subject #{proc_source(_subject)}"
      when Hash
        subject_name  = _subject.keys.first
        subject_value = _subject.values.first

        case subject_value
        when NamedProc
          "subject(:#{subject_name}) #{subject_value}"
        when Proc
          "subject(:#{subject_name}) #{proc_source(subject_value)}"
        else
          "subject { #{subject_value} }"
        end
      else
        value
      end
    end
  end

  module Core
    class ExampleGroup
      extend ::RSpec::Paramz::ExampleGroupMethods
    end
  end
end
