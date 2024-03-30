class_name Player
extends AnimatedSprite2D


#func _ready():


func _process(delta: float):
	var animation_speed = 1.0
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT.rotated(rotation) * 400 * delta
	elif Input.is_action_pressed("ui_right"):
		animation_speed = 2.0
		velocity = Vector2.RIGHT.rotated(rotation) * 400 * delta
	play("swim", animation_speed)
	if velocity.length() > 0:
		position += velocity
