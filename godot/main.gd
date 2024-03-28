extends Node

func _on_cpp_ship_position_changed(node, new_pos):
	print("The position of " + node.get_class() + " is now " + str(new_pos))
