extends Node


func _ready():
	read_sprites()
	read_tiles()
	get_tree().call_group("scenery", "prep_info")


func read_sprites():
	var nodes := get_tree().get_nodes_in_group("scenery")
	var refs := {} # String, Sprite
	var min_scale := INF
	var max_scale := 0.0
	for node in nodes:
		for kid in node.get_children():
			if kid is Sprite2D:
				var path := kid.texture.resource_path as String
				var scale := kid.scale.x as float
				min_scale = min(min_scale, scale)
				max_scale = max(max_scale, scale)
				print(kid.name, ": ", scale, ", ", path)
				refs[path] = kid
	print(refs)
	print(min_scale, ", ", max_scale)


func read_tiles():
	var tiles := $Ground/TileMap as TileMap
	var tile_set := tiles.tile_set
	var source := tile_set.get_source(0) as TileSetAtlasSource
	for i in range(0, source.get_tiles_count()):
		var tile_id := source.get_tile_id(i)
		#var alt := source.get_alternative_tile_id(i)
		var region := source.get_tile_texture_region(tile_id, 0)
		print(tile_id, ": ", region)
	var coords := tiles.get_used_cells(0)
	coords.sort()
	for coord in coords:
		print(coord, ": ", tiles.get_cell_atlas_coords(0, coord))
		#tiles.set_cell(0, coord)


func _on_cpp_ship_position_changed(node: Node, new_pos: Vector2):
	#print("The position of " + node.get_class() + " is now " + str(new_pos))
	pass
