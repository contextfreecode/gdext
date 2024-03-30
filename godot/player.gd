class_name Player
extends AnimatedSprite2D


@export var speed := 550.0

#func _ready():


func _process(delta: float):
	var animation_speed = 1.0
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation)
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation)
	elif Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT.rotated(rotation)
	elif Input.is_action_pressed("ui_right"):
		animation_speed = 2.0
		velocity = Vector2.RIGHT.rotated(rotation)
	play("swim", animation_speed)
	if velocity.length() > 0:
		position += velocity * speed * delta
