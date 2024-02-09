extends Node3D

const HAND = preload("res://hand.png")

@export var outline_node : Node3D
@export var tiltable_model : Node3D
@export var wobble_perlin_x : Noise = FastNoiseLite.new()
@export var wobble_perlin_y : Noise = FastNoiseLite.new()
@export var wobble_perlin_z : Noise = FastNoiseLite.new()
@export var wobble_amp : Vector3 = Vector3(1.0, 1.0, 0.5)
@export var drag_tilt_amp : Vector3 = Vector3(1.0, 1.0, 0.5)

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

var angle_facing : Vector3 = Vector3(0,0,0)

func _ready():
	if outline_node: outline_node.hide()
	var scrnsize = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var scrnarea = scrnsize.x * scrnsize.y
	var area_fraction_coverage_desired = 0.25
	var myarea = scrnarea * area_fraction_coverage_desired
	var mysidelength = roundi(sqrt(myarea)/100.0)*100
	get_window().position = Vector2i(scrnsize.x / 2, scrnsize.y) - get_window().size / 2
	get_window().size = Vector2i.ONE * mysidelength

func sign(a) -> int:
	if a < 0: return -1
	if a > 0: return 1
	return 0

func _physics_process(delta):
	if tiltable_model:
		tiltable_model.rotation = angle_facing
	
	var t : float = fmod(Time.get_unix_time_from_system(), 99999)
	
	var base_angle : Vector3 = Vector3(
		wobble_perlin_x.get_noise_1d(t) * wobble_amp.x,
		wobble_perlin_y.get_noise_1d(t) * wobble_amp.y,
		wobble_perlin_z.get_noise_1d(t) * wobble_amp.z
	)
	angle_facing -= base_angle
	if window_velocity.length_squared() > 0 :
		var min_window_velocity=-window_velocity.normalized()*(.15+.05*window_velocity.length())
		angle_facing.y = lerp(angle_facing.y, min_window_velocity.x * drag_tilt_amp.x, 0.1)
		angle_facing.x = lerp(angle_facing.x, min_window_velocity.y * drag_tilt_amp.y, 0.1)
		angle_facing.z = lerp(angle_facing.z, min_window_velocity.x * drag_tilt_amp.z, 0.1)
	else :
		angle_facing.y = lerp(angle_facing.y, 0.0, 0.1)
		angle_facing.x = lerp(angle_facing.x, 0.0, 0.1)
		angle_facing.z = lerp(angle_facing.z, 0.0, 0.1)
	if angle_facing.length() > 0.2:
		angle_facing *= 0.95
	angle_facing += base_angle
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
		var wpmin = get_window().position + get_window().size * 1 / 5
		var wpmax = wpmin + get_window().size * 3 / 5
		var scrnsize = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
		if wpmin.x < 0: window_velocity.x += 0.1 * -wpmin.x
		if wpmin.y < 0: window_velocity.y += 0.1 * -wpmin.y
		if wpmax.x > scrnsize.x: window_velocity.x += 0.1 * (scrnsize.x-wpmax.x)
		if wpmax.y > scrnsize.y: window_velocity.y += 0.1 * (scrnsize.y-wpmax.y)
		window_velocity *= 0.84 # slow down gradually
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
