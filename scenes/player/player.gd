extends "res://scenes/character/character.gd"

func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		var shoot_vec = get_global_mouse_position() - position
		$gun.shoot(shoot_vec)
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
