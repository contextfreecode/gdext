class_name Scenery
extends Node2D


@export_range(100, 1000, 50) var speed := 500.0


func prep_info(sprite_info_: SpriteInfo, tile_info_: TileInfo):
	sprite_info = sprite_info_
	tile_info = tile_info_
	print("prep_info: ", name, ", ", sprite_info, ", ", tile_info)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= delta * speed
	#tile_map.get_cell_tile_data()


var sprite_info: SpriteInfo
var tile_info: TileInfo
@onready var tile_map = $TileMap


class SpriteInfo:
	var max_scale := 0.0
	var min_scale := INF
	var refs: Dictionary # String, Array[Sprite2D]


class TileInfo:
	var nexts: Dictionary # Vector2, Array#[Vector2]
