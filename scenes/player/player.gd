extends "res://scenes/character/character.gd"

func _physics_process(delta):
	var look_vec = get_global_mouse_position() - position
	set_rot(look_vec.angle())
	if Input.is_action_pressed("shoot"):
		$gun.shoot(look_vec)
	var move_vec = lrud() * speed * delta
	move(move_vec)

func lrud() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	return input.normalized()
