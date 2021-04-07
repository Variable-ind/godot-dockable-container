extends Resource

const Layout = preload("res://addons/dockable_container/layout.gd")

var parent setget , get_parent
var root setget set_root, get_root
var data: Dictionary

var _root: Layout.LayoutNode


func set_root(value: Layout.LayoutNode) -> void:
	_root = value
	_root.parent = self


func get_root() -> Layout.LayoutNode:
	return _root


func get_parent():
	return null


func update_indices(indices) -> void:
	"""
	Add missing nodes on first leaf and remove nodes outside indices from leaves.
	
	data = {
		(numeric keys) from ... to = respective Leaf that holds the node index,
		first = first leaf,
	}
	"""
	data = { indices = indices }
	_root._ensure_indices_in_range(data)
	var first = data.first
	assert(first, "FIXME: no leaves were found in tree")
	for i in indices:
		if not data.has(i):
			first.push_node(i)
			data[i] = first


func move_node_to_leaf(node_index: int, leaf, relative_position: int) -> void:
	var previous_leaf = data[node_index]
	previous_leaf.remove_node(node_index)
	if previous_leaf.empty():
		_remove_leaf(previous_leaf)
	
	leaf.insert_node(relative_position, node_index)
	data[node_index] = leaf
#	_print_tree()
	emit_changed()


func get_leaf_for_node(node_index: int):
	return data.get(node_index)


func split_leaf_with_node(leaf, node_index: int, margin: int) -> void:
	var root_branch = leaf.parent
	var new_leaf = Layout.LayoutPanel.new()
	var new_branch = Layout.LayoutSplit.new()
	new_branch.split = margin
	new_branch.first = leaf
	new_branch.second = new_leaf
	if root_branch == self:
		self.root = new_branch
	elif leaf == root_branch.first:
		root_branch.first = new_branch
	else:
		root_branch.second = new_branch
	
	move_node_to_leaf(node_index, new_leaf, 0)


func _remove_leaf(leaf) -> void:
	assert(leaf.empty(), "FIXME: trying to remove a leaf with nodes")
	var collapsed_branch = leaf.parent
	if collapsed_branch == self:
		return
	assert(collapsed_branch is Layout.LayoutSplit, "FIXME: leaf is not a child of branch")
	var kept_branch = collapsed_branch.first if leaf == collapsed_branch.second else collapsed_branch.second
	var root_branch = collapsed_branch.parent
	if root_branch == self:
		self.root = kept_branch
	elif collapsed_branch == root_branch.first:
		root_branch.first = kept_branch
	else:
		root_branch.second = kept_branch


func _print_tree() -> void:
	print("TREE")
	_print_tree_step(_root, 0, 0)
	print("")


func _print_tree_step(tree_or_leaf, level, idx) -> void:
	if tree_or_leaf is Layout.LayoutPanel:
		print(" |".repeat(level), "- (%d) = " % idx, tree_or_leaf.nodes)
	else:
		print(" |".repeat(level), "-+ (%d) = " % idx, tree_or_leaf.split, " ", tree_or_leaf.percent)
		_print_tree_step(tree_or_leaf.first, level + 1, 1)
		_print_tree_step(tree_or_leaf.second, level + 1, 2)