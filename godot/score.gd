extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_ship_attacked():
	score += 1
	text = " Score %s " % score


var score := 0
