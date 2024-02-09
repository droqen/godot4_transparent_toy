@tool
extends Node2D
@export var size : Vector2i = Vector2i(320, 240)
@export var board_outline_colour : Color = Color.GREEN_YELLOW
var _prev_size : Vector2i
func _process(_delta):
	if _prev_size != size:
		_prev_size = size
		queue_redraw()
func _draw():
	if Engine.is_editor_hint():
		draw_rect(Rect2(0,0,size.x,size.y), board_outline_colour, false)
		draw_rect(Rect2(-1,-1,size.x+2,size.y+2), board_outline_colour, false)
