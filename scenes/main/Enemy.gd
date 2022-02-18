extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var bullet_scene = preload("res://scenes/bullet.tscn")

export var speed : int = 500
export var attack_speed : float = 3
export var attack_spread : float = .1

var health : int = 100
var attack_cur : float = -1

func _ready():
	rng.randomize()

func _physics_process(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1
			
	if attack_cur == -1:
		var bullet = bullet_scene.instance()
		var player = $"../player"
		if player:
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(position, player.position, [self])
			if result.collider == player:
				var angle = (player.position - position).angle()
				bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
				bullet.position = position
				bullet.group = "players"
				bullet.collision_mask = 3 #walls and players
				get_parent().add_child(bullet)
				attack_cur = 0
				
	#move code

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()
