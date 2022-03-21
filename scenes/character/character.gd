extends KinematicBody2D

export var max_health : int = 100
export var speed : float = 500
export var god : bool = false
export var health_visible_time : float = 5

var health : int = max_health
var cur_health_visible_time : float = -1

func _process(delta):
	if cur_health_visible_time >= 0:
		cur_health_visible_time += delta
		if cur_health_visible_time >= health_visible_time:
			cur_health_visible_time = -1
			$health_bar.visible = false

func move(move_vec):
	var collision = move_and_collide(move_vec)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))

func hurt(damage):
	if !god:
		health -= damage
		$health_bar.value = health
		cur_health_visible_time = 0
		$health_bar.visible = true
		if health <= 0:
			queue_free()

func set_rot(rad: float):
	$direction_indicator.rect_rotation = rad2deg(rad)
	
func get_rot() -> float:
	return deg2rad($direction_indicator.rect_rotation)
