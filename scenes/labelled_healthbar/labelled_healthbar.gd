extends ProgressBar

var character: Node2D

func _process(delta):
	if character:
		if is_instance_valid(character):
			var health = int(character.get_node("health_bar").value)
			set_health(health)
		else:
			character = null
			set_health(0)

func set_health(health: int):
	value = health
	$Label.text = str(health)
	center_control($Label)
	
func get_health() -> int:
	return int(value)

func center_control(control : Control):
	var size = control.get_minimum_size()
	control.margin_left = -size.x/2
	control.margin_right = size.x/2
	control.margin_top = -size.y/2
	control.margin_bottom = size.y/2
