class_name Player
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_right"):
		velocity = Vector2.RIGHT.rotated(rotation) * 400 * delta
	position += velocity
