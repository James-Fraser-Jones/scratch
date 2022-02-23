extends KinematicBody2D

export var max_health : int = 100
export var speed : int = 500

var health : int = max_health

func _physics_process(delta):
	control(delta)

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()

func move(move_vec):
	var collision = move_and_collide(move_vec)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))

func control(delta):
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
