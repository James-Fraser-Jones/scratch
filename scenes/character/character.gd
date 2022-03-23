extends KinematicBody2D

export var max_health : int = 100
export var speed : float = 500
export var god : bool = false
export var health_visible_time : float = 5
export var damage_number_time : float = 0.1
export var damage_number_rise : float = 6
export var damage_number_lean_range : float = 16

const damage_number_scene = preload("res://scenes/damage_number/damage_number.tscn")

onready var health : int = max_health #onready necessary to allow player scene to overwrite using its own max_health
var cur_health_visible_time : float = -1

func _ready():
	$health_bar.max_value = max_health
	$health_bar.value = max_health

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

func hurt(damage: int):
	if !god:
		health -= damage
		$health_bar.value = health
		
		cur_health_visible_time = 0
		$health_bar.visible = true
		
		var damage_number = damage_number_scene.instance()
		damage_number.text = str(damage)
		damage_number.rect_position.y -= 40
		damage_number.time = damage_number_time * damage
		damage_number.rise = damage_number_rise * damage
		damage_number.lean_range = damage_number_lean_range * damage
		add_child(damage_number)
		
		if health <= 0:
			queue_free()
			return

func set_rot(rad: float):
	$direction_indicator.rect_rotation = rad2deg(rad)
	
func get_rot() -> float:
	return deg2rad($direction_indicator.rect_rotation)
