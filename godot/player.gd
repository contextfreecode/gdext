class_name Player
extends Area2D

@export var speed := 550.0


func _ready():
	var ref := get_tree().root.get_node("Main/Bounds") as ReferenceRect
	bounds_min = ref.get_rect().position
	bounds_max = ref.get_rect().size + bounds_min
	var extent := read_sprite_frames()
	bounds_max -= extent
	bounds_min += extent
	#print("bounds: ", bounds)


func _process(delta: float):
	var animation_speed = 1.0
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		animation_speed = 2.0
		velocity = Vector2.RIGHT
	sprite.play("swim", animation_speed)
	if velocity.length() > 0:
		position += velocity * speed * delta
	# Bound things.
	position.x = max(position.x, bounds_min.x)
	position.y = max(position.y, bounds_min.y)
	position.x = min(position.x, bounds_max.x)
	position.y = min(position.y, bounds_max.y)


func read_sprite_frames() -> Vector2:
	var frames := sprite.sprite_frames as SpriteFrames
	var anim := sprite.animation as StringName
	var size_x := 0.0
	var size_y := 0.0
	for index in range(0, frames.get_frame_count(anim)):
		var frame := frames.get_frame_texture(anim, index)
		size_x = max(size_x, frame.get_width())
		size_y = max(size_y, frame.get_height())
	return Vector2(size_x / 2, size_y / 2)


var bounds_max: Vector2
var bounds_min: Vector2
@onready var sprite := $Sprite
