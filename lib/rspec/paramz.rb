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
          raise ArgumentError, "No block or subject given to paramz."
        end

        labels = args.first
        labels = labels.call if labels.respond_to?(:call)
        args[1..].each do |arg|
          location = arg.source_location
          source = spec_file_content(location.first).each_line.to_a[location[1] - 1].strip.delete_suffix(",")
          context_name = source

          context context_name do
            result = Prism.parse(source)
            val = result.value
            nodes = val.compact_child_nodes.first.compact_child_nodes.first.body.compact_child_nodes.first.elements
            nodes.each.with_index do |node, index|
              let(labels[index]) do
                if node.type == :true_node
                  true
                elsif node.type == :false_node
                  false
                elsif node.type == :nil_node
                  nil
                elsif node.respond_to?(:value)
                  node.value
                elsif node.respond_to?(:content)
                  node.content
                elsif node.respond_to?(:name)
                  __send__(node.name)
                else
                  loc = node.location
                  eval(source[loc.start_offset...loc.end_offset]) # rubocop:disable Security/Eval
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
