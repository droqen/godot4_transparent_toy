extends Node3D

const HAND = preload("res://hand.png")

@export var outline_node : Node3D

var hovering_over : bool = false
var dragging : bool = false
var drag_start_monitor_mouse_pos : Vector2i
var drag_start_window_pos : Vector2i

var window_velocity : Vector2
var window_subposition : Vector2

var mousewheel_buf : int = 0
var mousewheel_value : int = 0
var between_resize_buf : int = 0

const RESIZE_FIRST_REPEAT : int = 60
const RESIZE_SUBSEQUENT_REPEAT : int = 60
const SIZE_MIN = 100
const RESIZE_STEP : int = 100

func _ready():
	if outline_node: outline_node.hide()
	var scrnsize = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var scrnarea = scrnsize.x * scrnsize.y
	var area_fraction_coverage_desired = 0.25
	var myarea = scrnarea * area_fraction_coverage_desired
	var mysidelength = roundi(sqrt(myarea)/100.0)*100
	get_window().position = Vector2i(scrnsize.x / 2, scrnsize.y) - get_window().size / 2
	get_window().size = Vector2i.ONE * mysidelength

func _physics_process(delta):
	var window_mouse_pos = get_window().get_mouse_position()
	var monitor_mouse_pos = (get_window().position as Vector2 + window_mouse_pos)
	var rorigin = $Camera3D.project_ray_origin(window_mouse_pos)
	var rtarget = $Camera3D.project_ray_normal(window_mouse_pos) * 100
	var toggle_hover : bool = false
	
	$Camera3D.environment.background_color = Color(0,0,0,0)
	
	if between_resize_buf > 0:
		between_resize_buf -= 1
	if mousewheel_buf > 0:
		mousewheel_buf -= 1
		if between_resize_buf <= 1:
			if between_resize_buf == 0:
				between_resize_buf = RESIZE_FIRST_REPEAT
			else:
				between_resize_buf = RESIZE_SUBSEQUENT_REPEAT
			var old_size = get_window().size.x
			var new_size = max(SIZE_MIN,
				old_size + mousewheel_value * (RESIZE_STEP)
			)
			get_window().position -= Vector2i.ONE * (new_size - old_size)/2
			get_window().size = Vector2i.ONE * (new_size)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if hovering_over and not dragging:
			dragging = true
			drag_start_monitor_mouse_pos = monitor_mouse_pos as Vector2i
			drag_start_window_pos = get_window().position
		if dragging:
			$Camera3D/Label3D.text = (
				"Drag start\n" + str(drag_start_window_pos)
				+ "\n\nWindow position\n" + str(get_window().position)
				+ "\n\nMonitor mouse pos\n" + str(monitor_mouse_pos as Vector2i)
			)
			var desired_window_position = drag_start_window_pos + (monitor_mouse_pos as Vector2i - drag_start_monitor_mouse_pos)
			var to_desired_window_position = desired_window_position - get_window().position
			window_velocity = lerp(window_velocity, to_desired_window_position as Vector2, 0.5)
			get_window().position += to_desired_window_position
		elif not hovering_over:
			$Camera3D.environment.background_color = Color(.1,.1,.1,.1)
	else:
		if dragging:
			dragging = false
	
	if not dragging:
		var wpmin = get_window().position
		var wpmax = wpmin + get_window().size
		var scrnsize = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
		if wpmin.x < 0: window_velocity.x += 0.1 * -wpmin.x
		if wpmin.y < 0: window_velocity.y += 0.1 * -wpmin.y
		if wpmax.x > scrnsize.x: window_velocity.x += 0.1 * (scrnsize.x-wpmax.x)
		if wpmax.y > scrnsize.y: window_velocity.y += 0.1 * (scrnsize.y-wpmax.y)
		window_velocity *= 0.75 # slow down RAPIDLY.
		window_subposition += window_velocity
		var window_move = window_subposition as Vector2i
		get_window().position += window_move
		window_subposition -= window_move as Vector2
	
	if hovering_over:
		if dragging:
			pass
		else:
			$RayCast3D.position = rorigin
			$RayCast3D.target_position = rtarget
			$RayCast3D.force_raycast_update()
			$ShapeCast3D.position = rorigin
			$ShapeCast3D.target_position = rtarget
			$ShapeCast3D.force_shapecast_update()
			if not ($RayCast3D.is_colliding() or $ShapeCast3D.is_colliding()):
				toggle_hover = true
	else:
		$RayCast3D.position = rorigin
		$RayCast3D.target_position = rtarget
		$RayCast3D.force_raycast_update()
		if $RayCast3D.is_colliding():
			toggle_hover = true
	
	if toggle_hover:
		hovering_over = not hovering_over
		if hovering_over:
			if outline_node: outline_node.show()
			Input.set_custom_mouse_cursor(HAND, 0, Vector2(8,9))
		else:
			if outline_node: outline_node.hide()
			Input.set_custom_mouse_cursor(null)

	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			mousewheel_value = -1
			mousewheel_buf = 12
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			mousewheel_value = 1
			mousewheel_buf = 12
