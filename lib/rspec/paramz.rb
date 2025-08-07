require "rspec/paramz/version"
require "prism"

class Lambda < Prism::Visitor
  attr_reader :calls

  def initialize(calls)
    @calls = calls
  end

  def visit_lambda_node(node)
    super(node)
    @calls << node.source
  end
end

module RSpec
  module Paramz
    module ExampleGroupMethods
      def paramz(*args, &block)
        unless block_given?
          raise ArgumentError, "No block given to paramz."
        end

        labels = args.first
        labels = labels.call if labels.respond_to?(:call)
        args[1..].each do |arg|
          location = arg.source_location
          source = spec_file_content(location.first).each_line.to_a[location[1] - 1].strip.delete_suffix(",")
          result = Prism.parse(source)
          lambda_node = result.value.compact_child_nodes.first.compact_child_nodes.first
          array_nodes = lambda_node.body.compact_child_nodes.first
          nodes = array_nodes.elements

          texts = nodes.map do |node|
            range = node.location.start_offset...node.location.end_offset
            source.byteslice(range)
          end

          context_name =
            "[#{[labels, texts].transpose.map {|label, text| "#{label} = #{text}" }.join(" | ")}]"

          context(context_name) do
            nodes.each.with_index do |node, index|
              let(labels[index]) do
                if node.type == :true_node
                  true
                elsif node.type == :false_node
                  false
                elsif node.type == :nil_node
                  nil
                elsif node.type == :symbol_node
                  node.value.to_sym
                elsif node.type == :string_node
                  node.unescaped
                elsif node.type == :array_node
                  range = node.opening_loc.start_offset...node.closing_loc.end_offset
                  eval(source.byteslice(range)) # rubocop:disable Security/Eval
                elsif node.respond_to?(:value)
                  node.value
                elsif node.respond_to?(:content)
                  node.content
                else
                  loc = node.location
                  eval(source[loc.start_character_offset...loc.end_code_units_offset]) # rubocop:disable Security/Eval
                end
              end
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

        def spec_file_content(path)
          @spec_file_content ||= {}
          @spec_file_content[path] ||= File.read(path)
        end
    end
  end

  module Core
    class ExampleGroup
      extend ::RSpec::Paramz::ExampleGroupMethods
    end
  end
end
