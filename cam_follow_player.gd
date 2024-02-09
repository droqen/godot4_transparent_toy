extends Camera2D

@export var follow_target : Node2D
func _physics_process(_delta):
	position = follow_target.position
