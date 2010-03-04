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
      if node = children.find {|c| c.name == name}
        node.add_child(names)
      else
        children << TreeNode.new(name, names)
      end
    end
    
    # Return an array representation of the tree
    def to_a
      [name, children.map {|c| c.to_a}]
    end
    
    # Return a :include comptatible statement from the tree
    def to_include
      children.map {|c| c.build_include}
    end
    
    # Return the include parameters for a child
    def build_include
      leaf_node? ? name.to_sym : { name.to_sym => children.map {|c| c.build_include} }
    end
    
    private
    
    def leaf_node?
      children.blank?
    end
  end
end