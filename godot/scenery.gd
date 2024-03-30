extends Node2D


func prep_info():
	print("prep_info: ", name)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


@onready var tile_map = $TileMap
