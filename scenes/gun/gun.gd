extends Node2D

export var attack_speed : float = 15
export var attack_spread : float = .1
export var col_mask : int = 7 #walls, players, enemies

var rng = RandomNumberGenerator.new()
var bullet_scene = preload("res://scenes/bullet/bullet.tscn")
var main : Node2D

var attack_cur : float = -1

func _ready():
	rng.randomize()
	main = $"/root/main"

func _physics_process(delta):
	shoot_timer(delta)

func shoot_timer(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1

func can_shoot():
	return attack_cur == -1

#API
func shoot(shoot_vec):
	if can_shoot():
		var bullet = bullet_scene.instance()
		var angle = shoot_vec.angle()
		bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
		bullet.position = global_position
		bullet.collision_mask = col_mask
		main.add_child(bullet)
		attack_cur = 0
