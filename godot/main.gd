extends Node


func _ready():
	var scenery_info = Scenery.Info.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	scenery_info.rng = rng
	scenery_info.sprite_info = read_sprites()
	scenery_info.tile_info = read_tiles()
	get_tree().call_group("scenery", "prep_info", scenery_info)
	for node in get_tree().get_nodes_in_group("ship"):
		node.connect("finished", _on_ship_finished)


func read_sprites() -> Scenery.SpriteInfo:
	var info := Scenery.SpriteInfo.new()
	var nodes := get_tree().get_nodes_in_group("scenery")
	var refs := {} # String, Sprite
	for node in nodes:
		for kid in node.get_children():
			if kid is Sprite2D:
				var path := kid.texture.resource_path as String
				var scale := kid.scale.x as float
				var end: Vector2 = kid.get_rect().end * kid.scale + kid.position
				info.bottom = max(info.bottom, end.y)
				info.min_scale = min(info.min_scale, scale)
				info.max_scale = max(info.max_scale, scale)
				print(kid.name, ": ", scale, ", ", path, ", ", kid.position, ", ", kid.get_rect(), ", ", end)
				if path not in info.refs:
					refs[path] = kid.duplicate()
	info.refs.assign(refs.values())
	print(info.refs)
	print(info.min_scale, ", ", info.max_scale)
	return info


func read_tiles() -> Scenery.TileInfo:
	var info := Scenery.TileInfo.new()
	var tile_map := $Ground/TileMap as TileMap
	var tile_set := tile_map.tile_set
	var source := tile_set.get_source(0) as TileSetAtlasSource
	for i in range(0, source.get_tiles_count()):
		var tile_id := source.get_tile_id(i)
		#var alt := source.get_alternative_tile_id(i)
		var region := source.get_tile_texture_region(tile_id, 0)
		print(tile_id, ": ", region)
	var coords_array := tile_map.get_used_cells(0)
	coords_array.sort()
	var last := Vector2i.ZERO
	for coords in coords_array:
		var data := tile_map.get_cell_tile_data(0, coords)
		var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
		var current_nexts := \
			info.nexts.get(last, [] as Array[Vector2i]) as Array[Vector2i]
		if last != Vector2i.ZERO and atlas_coords not in current_nexts:
			current_nexts.append(atlas_coords)
			info.nexts[last] = current_nexts
		#data.set_custom_data()
		#print(coords, ": ", atlas_coords, ", ", last, ", ", current_nexts)
		#tile_map.set_cell(0, coords)
		last = atlas_coords
	print(info.nexts)
	return info


# The "null" default is for testing emit without args.
func _on_ship_finished(node: Node = null):
	print("Ship finished: ", node, ", ", node == $Ships/RustShip)
