# frozen_string_literal: true

module Rexport #:nodoc:
  # A basic tree for building up ActiveRecord find :include parameters
  class TreeNode
    attr_accessor :name, :children

    # Initialize a tree node setting name and adding a child if one was passed
    def initialize(name, *names)
      self.name = name
      self.children = []
      add_child(names)
    end

    # Add one or more children to the tree
    def add_child(*names)
      names.flatten!
      return unless name = names.shift
      node = children.find { |c| c.name == name }
      node ? node.add_child(names) : (children << TreeNode.new(name, names))
    end

    # Return an array representation of the tree
    def to_a
      [name, children.map(&:to_a)]
    end

    # Return a :include comptatible statement from the tree
    def to_include
      children.map(&:build_include)
    end

    # Return the include parameters for a child
    def build_include
      leaf_node? ? name.to_sym : { name.to_sym => children.map(&:build_include) }
    end

    private

    def leaf_node?
      children.blank?
    end
  end
end
