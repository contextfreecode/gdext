class_name Player
extends AnimatedSprite2D


#func _ready():


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
	if velocity.length() > 0:
		play("swim")
		position += velocity
	else:
		stop()
