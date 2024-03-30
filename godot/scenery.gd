extends Node2D


@export_range(100, 1000, 50) var speed := 500.0


func prep_info():
	print("prep_info: ", name)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= delta * speed


@onready var tile_map = $TileMap
