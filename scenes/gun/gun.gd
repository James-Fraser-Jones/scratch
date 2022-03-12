extends Node2D

export var attack_speed : float = 15
export var attack_spread : float = .1

export var bullet_damage : int = 5
export var bullet_modulate : Color = Color.white
export var col_mask : int = 0

const bullet_scene = preload("res://scenes/bullet/bullet.tscn")
onready var main : Node2D = $"/root/main"

var attack_cur : float = -1

func _physics_process(delta):
	shoot_timer(delta)

func shoot_timer(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1

func can_shoot():
	return attack_cur == -1

func shoot(shoot_vec):
	if can_shoot():
		var bullet = bullet_scene.instance()
		var angle = shoot_vec.angle()
		bullet.rotation = angle + PI/2 + rand_range(-attack_spread/2, attack_spread/2)
		bullet.position = global_position
		bullet.collision_mask = col_mask
		bullet.damage = bullet_damage
		bullet.modulate = bullet_modulate
		main.add_child(bullet)
		attack_cur = 0
