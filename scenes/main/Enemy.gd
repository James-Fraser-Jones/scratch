extends KinematicBody2D

var rng = RandomNumberGenerator.new()

var bullet_scene = preload("res://scenes/bullet.tscn")

var nav : Navigation2D
var player : KinematicBody2D

export var speed : int = 350
export var attack_speed : float = 3
export var attack_spread : float = .1

var health : int = 100
var attack_cur : float = -1

func _ready():
	rng.randomize()
	nav = $"../nav"
	player = $"../player"

func _physics_process(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1
	
	if is_instance_valid(player):
		if attack_cur == -1:
			var bullet = bullet_scene.instance()
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(position, player.position, [self])
			if result and result.collider == player:
				var angle = (player.position - position).angle()
				bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
				bullet.position = position
				bullet.group = "players"
				bullet.collision_mask = 3 #walls and players
				get_parent().add_child(bullet)
				attack_cur = 0
		
		var nav_pos = nav.get_simple_path(position, player.position)[1]
		var movement = (nav_pos - position).normalized() * speed * delta
		var collision = move_and_collide(movement)
		if collision:
			move_and_collide(collision.remainder.slide(collision.normal))

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()
