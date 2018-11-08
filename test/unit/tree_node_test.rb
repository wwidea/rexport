require 'test_helper'

class TreeNodeTest < ActiveSupport::TestCase
  def test_should_initialize_with_name
    t = Rexport::TreeNode.new('test')
    assert_equal('test', t.name)
    assert_equal([], t.children)
  end

  def test_should_initialize_with_name_and_children
    t = Rexport::TreeNode.new('test', %w(one two three))
    assert_equal('test', t.name)
    assert_equal(["test", [["one", [["two", [["three", []]]]]]]], t.to_a)
  end

  def test_should_add_children
    root = Rexport::TreeNode.new('root')
    root.add_child('a')
    assert_equal(['root', [['a', []]]], root.to_a)
    root.add_child('a')
    assert_equal(['root', [['a', []]]], root.to_a)
    root.add_child('a', [1 , 2])
    assert_equal(['root', [['a', [[1, [[2, []]]]]]]], root.to_a)
  end

  def test_should_return_empty_include
    root = Rexport::TreeNode.new('root')
    assert_equal([], root.to_include)
  end

  def test_should_return_single_level_array_include
    root = Rexport::TreeNode.new('root')
    %w(a b c).each {|l| root.add_child(l)}
    assert_equal([:a, :b, :c], root.to_include)
  end

  def test_should_return_nested_hash_include
    root = Rexport::TreeNode.new('root', %w(a b c))
    assert_equal([{a: [{b: [:c]}]}], root.to_include)
    root.add_child('b', 'one', 'two')
    assert_equal([{a: [{b: [:c]}]}, {b: [{one:[:two]}]}], root.to_include)
  end
end
