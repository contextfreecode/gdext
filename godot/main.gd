extends Node


func _ready():
	var sprite_info := read_sprites()
	var tile_info := read_tiles()
	get_tree().call_group("scenery", "prep_info", sprite_info, tile_info)


func read_sprites() -> Scenery.SpriteInfo:
	var info := Scenery.SpriteInfo.new()
	var nodes := get_tree().get_nodes_in_group("scenery")
	var refs := {} # String, Sprite
	for node in nodes:
		for kid in node.get_children():
			if kid is Sprite2D:
				var path := kid.texture.resource_path as String
				var scale := kid.scale.x as float
				info.min_scale = min(info.min_scale, scale)
				info.max_scale = max(info.max_scale, scale)
				print(kid.name, ": ", scale, ", ", path)
				info.refs[path] = kid
	print(info.refs)
	print(info.min_scale, ", ", info.max_scale)
	return info


func read_tiles() -> Scenery.TileInfo:
	var info := Scenery.TileInfo.new()
	var tiles := $Ground/TileMap as TileMap
	var tile_set := tiles.tile_set
	var source := tile_set.get_source(0) as TileSetAtlasSource
	for i in range(0, source.get_tiles_count()):
		var tile_id := source.get_tile_id(i)
		#var alt := source.get_alternative_tile_id(i)
		var region := source.get_tile_texture_region(tile_id, 0)
		print(tile_id, ": ", region)
	var coords_array := tiles.get_used_cells(0)
	coords_array.sort()
	var last := Vector2.ZERO
	for coords in coords_array:
		var data := tiles.get_cell_tile_data(0, coords)
		var atlas_coords := tiles.get_cell_atlas_coords(0, coords)
		var current_nexts := info.nexts.get(last, []) as Array
		if last != Vector2.ZERO and atlas_coords not in current_nexts:
			current_nexts.append(atlas_coords)
			info.nexts[last] = current_nexts
		#data.set_custom_data()
		print(coords, ": ", atlas_coords, ", ", last, ", ", current_nexts)
		#tiles.set_cell(0, coords)
		last = atlas_coords
	print(info.nexts)
	return info


func _on_cpp_ship_position_changed(node: Node, new_pos: Vector2):
	#print("The position of " + node.get_class() + " is now " + str(new_pos))
	pass
