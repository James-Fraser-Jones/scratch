extends Control

export var time : float = 1
export var rise : float = 1
export var lean_range : float = 1

var cur_time : float = 0
onready var lean = rand_range(-lean_range, lean_range)

func _process(delta):
	cur_time += delta
	if cur_time >= time:
		queue_free()
		return
	
	var scale = delta/time
	rect_position.y -= rise*scale
	rect_position.x += lean*scale
	modulate.a -= scale

func set_number(number: int):
	$Label.text = str(number)
	center_control($Label)

func center_control(control : Control):
	var size = control.get_minimum_size()
	control.margin_left = -size.x/2
	control.margin_right = size.x/2
	control.margin_top = -size.y/2
	control.margin_bottom = size.y/2
