class_name Scenery
extends Node2D


@export_range(100, 1000, 50) var speed := 400.0


func prep_info(info_: Info):
	info = info_
	print("prep_info: ", name, ", ", info_)


# Called when the node enters the scene tree for the first time.
func _ready():
	var coords_array := tile_map.get_used_cells(0)
	last_tile_coords = coords_array.max()
	viewport_size = get_viewport_rect().size
	print(last_tile_coords, ": ", tile_map.map_to_local(last_tile_coords))
	for kid in get_children():
		if kid is Sprite2D:
			last_sprite_x = max(last_sprite_x, kid.position.x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= delta * speed
	var viewport_right := viewport_size.x - position.x
	if last_sprite_x < viewport_right + gen_x:
		print("ha: ", last_sprite_x, " vs ", viewport_right + gen_x)
		place_sprite(max(viewport_right, last_sprite_x) + 300)
	var last_tile_x := tile_map.map_to_local(last_tile_coords).x
	if last_tile_x < viewport_right + gen_x:
		print("hi: ", last_tile_x, " vs ", viewport_right)
		place_tile()
	# TODO Extend scenery. Clean up old.
	#tile_map.get_cell_tile_data()
	if position.x < -reset_x:
		reset_scenery()


func place_sprite(min_x: float):
	var refs := info.sprite_info.refs
	var ref := refs[info.rng.randi_range(0, refs.size() - 1)]
	var sprite := ref.duplicate() as Sprite2D
	var x = info.rng.randf_range(min_x, min_x + 1200)
	var scale := info.rng.randf_range(
		info.sprite_info.min_scale, info.sprite_info.max_scale
	)
	sprite.scale = Vector2(scale, scale)
	var y := info.sprite_info.bottom - sprite.get_rect().end.y * scale
	sprite.position = Vector2(x, y)
	print("bottom: ", info.sprite_info.bottom, ", ", sprite.get_rect(), ", ", sprite.position)
	last_sprite_x = x
	add_child(sprite)
	move_child(sprite, 0)


func place_tile():
	var current := tile_map.get_cell_atlas_coords(0, last_tile_coords)
	var nexts: Array[Vector2i] = info.tile_info.nexts[current]
	var next_index := info.rng.randi_range(0, nexts.size() - 1)
	var next_tile = nexts[next_index]
	last_tile_coords = Vector2i(last_tile_coords.x + 1, last_tile_coords.y)
	tile_map.set_cell(0, last_tile_coords, 0, next_tile)


func reset_scenery():
	reset_sprites()
	# Changes position.x!!!
	reset_tiles()


func reset_sprites():
	for kid in get_children():
		if kid is Sprite2D:
			kid.position.x -= reset_x
			if kid.position.x < -gen_x:
				kid.queue_free()
				print("free: ", kid, ", ", kid.position.x)
	last_sprite_x -= reset_x


func reset_tiles():
	var from := start_tile()
	position.x += reset_x
	var to := start_tile()
	var tile_width := tile_map.tile_set.tile_size.x
	# The +1 and many other things in the script are slop on my part.
	# I haven't worked out perfect logic.
	var needed := ceili(viewport_size.x / float(tile_width)) + 1
	for i in range(0, needed):
		last_tile_coords = Vector2i(to.x + i, to.y)
		tile_map.set_cell(
			0, last_tile_coords,
			0, tile_map.get_cell_atlas_coords(0, Vector2i(from.x + i, to.y)),
		)


func start_tile() -> Vector2i:
	return tile_map.local_to_map(Vector2(-position.x, viewport_size.y))


var gen_x := 200.0
var info: Info
var last_sprite_x := -INF
var last_tile_coords: Vector2i
var reset_x := 2000.0
@onready var tile_map: TileMap = $TileMap
var viewport_size: Vector2i


class Info:
	var rng: RandomNumberGenerator
	var sprite_info: SpriteInfo
	var tile_info: TileInfo


class SpriteInfo:
	var bottom := -INF
	var max_scale := -INF
	var min_scale := INF
	var refs: Array[Sprite2D]


class TileInfo:
	var nexts: Dictionary # Vector2i, Array[Vector2i]
