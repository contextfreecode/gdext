extends Node

signal ship_attacked


func _ready():
	var scenery_info = Scenery.Info.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	scenery_info.rng = rng
	scenery_info.sprite_info = read_sprites()
	scenery_info.tile_info = read_tiles()
	get_tree().call_group("scenery", "prep_info", scenery_info)
	for node in get_tree().get_nodes_in_group("ship"):
		node.connect("attack_finished", _on_ship_attack_finished)
		waiting_ships.append(node)
	schedule_attacks(rng)


func _process(delta: float):
	if zig_sprite.position.x > zig_sprite_old_x:
		zig_ship.emit_signal(&"attack_finished", zig_ship)
	zig_sprite_old_x = zig_sprite.position.x


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


func _on_player_area_entered(area: Area2D):
	var parent := area.get_parent()
	if &"ship" in parent.get_groups():
		animation_player.play("fade")
		get_tree().paused = true


# The "null" default is for testing emit without args.
func _on_ship_attack_finished(node: Node = null):
	print("Ship finished: ", node)


func schedule_attacks(rng: RandomNumberGenerator):
	while true:
		await get_tree().create_timer(rng.randf_range(0.0, 1.0)).timeout
		if waiting_ships.is_empty():
			if finished_ships.is_empty():
				continue
			waiting_ships.append_array(finished_ships)
			finished_ships.clear()
		var index := rng.randi_range(0, waiting_ships.size() - 1)
		var ship := waiting_ships.pop_at(index) as Node
		ship.attack(0.0, 0.0, 0.0)
		ship_attacked.emit()
		await wait_for_ship(ship)


func wait_for_ship(ship: Node):
	await ship.attack_finished
	finished_ships.append(ship)


var finished_ships: Array[Node]
var waiting_ships: Array[Node]
var zig_sprite_old_x := INF

@onready var animation_player := $AnimationPlayer as AnimationPlayer

# Work around trouble sending signals from Zig.
@onready var zig_ship = $Actors/Ships/ZigShip
@onready var zig_sprite = $Actors/Ships/ZigShip/Sprite
