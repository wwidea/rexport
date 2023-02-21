# frozen_string_literal: true

require "test_helper"

class TreeNodeTest < ActiveSupport::TestCase
  test "should initialize with name" do
    t = Rexport::TreeNode.new("test")
    assert_equal "test", t.name
    assert_equal [], t.children
  end

  test "should initialize with name and children" do
    t = Rexport::TreeNode.new("test", %w(one two three))
    assert_equal "test", t.name
    assert_equal ["test", [["one", [["two", [["three", []]]]]]]], t.to_a
  end

  test "should add children" do
    root = Rexport::TreeNode.new("root")
    root.add_child("a")
    assert_equal ["root", [["a", []]]], root.to_a
    root.add_child("a")
    assert_equal ["root", [["a", []]]], root.to_a
    root.add_child("a", [1 , 2])
    assert_equal ["root", [["a", [[1, [[2, []]]]]]]], root.to_a
  end

  test "should return empty include" do
    root = Rexport::TreeNode.new("root")
    assert_equal [], root.to_include
  end

  test "should return single level array include" do
    root = Rexport::TreeNode.new("root")
    %w(a b c).each { |l| root.add_child(l) }
    assert_equal [:a, :b, :c], root.to_include
  end

  test "should return nested hash include" do
    root = Rexport::TreeNode.new("root", %w(a b c))
    assert_equal [{ a: [{ b: [:c] }] }], root.to_include
    root.add_child "b", "one", "two"
    assert_equal [{ a: [{ b: [:c] }] }, { b: [{ one:[:two] }] }], root.to_include
  end
end
