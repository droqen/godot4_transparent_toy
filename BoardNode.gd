@tool
extends Node2D
@export var size : Vector2i = Vector2i(320, 240)
@export var board_outline_colour : Color = Color.GREEN_YELLOW
@export var bleed : int = 10
var _prev_bleed : int
var _prev_size : Vector2i
func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func _process(_delta):
	position = Vector2i(bleed,bleed) as Vector2
	if _prev_bleed != bleed:
		_prev_bleed = bleed
		queue_redraw()
	if _prev_size != size:
		_prev_size = size
		queue_redraw()
func _draw():
	draw_rect(Rect2(-bleed,-bleed,size.x+bleed*2,size.y+bleed*2), Color.BLACK, true)
	if Engine.is_editor_hint():
		draw_rect(Rect2(0,0,size.x,size.y), board_outline_colour, false)
		draw_rect(Rect2(-1,-1,size.x+2,size.y+2), board_outline_colour, false)
