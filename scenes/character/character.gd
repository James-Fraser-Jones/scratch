extends KinematicBody2D

export var max_health : int = 100
export var speed : float = 500
export var god : bool = false

var health : int = max_health

func move(move_vec):
	var collision = move_and_collide(move_vec)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))

func hurt(damage):
	if !god:
		health -= damage
		$health_bar.value = health
		if health <= 0:
			queue_free()

func set_rot(rad: float):
	$direction_indicator.rect_rotation = rad2deg(rad)
	
func get_rot() -> float:
	return deg2rad($direction_indicator.rect_rotation)
