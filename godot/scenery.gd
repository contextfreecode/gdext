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
	viewport_size = get_window().size
	print(last_tile_coords, ": ", tile_map.map_to_local(last_tile_coords))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= delta * speed
	var viewport_right := viewport_size.x + position.x
	if last_tile_coords.x < viewport_right + 500:
		place_tile()
	# TODO Extend scenery. Clean up old.
	#tile_map.get_cell_tile_data()


func place_tile():
	var current := tile_map.get_cell_atlas_coords(0, last_tile_coords)
	var nexts: Array[Vector2i] = info.tile_info.nexts[current]
	var next_index := info.rng.randi_range(0, nexts.size() - 1)
	var next_tile = nexts[next_index]
	last_tile_coords = Vector2i(last_tile_coords.x + 1, last_tile_coords.y)
	tile_map.set_cell(0, last_tile_coords, 0, next_tile)


var info: Info
var last_tile_coords: Vector2i
@onready var tile_map: TileMap = $TileMap
var viewport_size: Vector2i


class Info:
	var rng: RandomNumberGenerator
	var sprite_info: SpriteInfo
	var tile_info: TileInfo


class SpriteInfo:
	var max_scale := 0.0
	var min_scale := INF
	var refs: Dictionary # String, Array[Sprite2D]


class TileInfo:
	var nexts: Dictionary # Vector2i, Array[Vector2i]
