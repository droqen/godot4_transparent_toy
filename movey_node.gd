extends Node2D
func _physics_process(_delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= randf()
	if Input.is_action_pressed("ui_right"):
		position.x += randf()
