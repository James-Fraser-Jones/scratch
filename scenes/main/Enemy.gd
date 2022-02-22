extends KinematicBody2D

#ability 1

export var attack_speed : float = 3
export var attack_spread : float = .1

var rng = RandomNumberGenerator.new()
var bullet_scene = preload("res://scenes/bullet.tscn")
var main : Node2D

var attack_cur : float = -1

#actual enemy vars

export var max_health : int = 100
export var speed : int = 350

var player : KinematicBody2D
var nav : Navigation2D

var health : int = max_health

func _ready():
	rng.randomize()
	main = get_parent()
	nav = $"../nav"
	player = $"../player"

func _physics_process(delta):
	shoot_timer(delta)
	control(delta)

func shoot_timer(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()

func shoot(shoot_vec, col_mask):
	if attack_cur == -1:
		var bullet = bullet_scene.instance()
		var angle = shoot_vec.angle()
		bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
		bullet.position = position
		bullet.collision_mask = col_mask
		main.add_child(bullet)
		attack_cur = 0

func move(move_vec):
	var collision = move_and_collide(move_vec)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))

func control(delta):
	if is_instance_valid(player):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, player.position, [self])
		if result and result.collider == player:
			var shoot_vec = player.position - position
			shoot(shoot_vec, 3) #walls and players
		
		var nav_pos = nav.get_simple_path(position, player.position)[1]
		var move_vec = (nav_pos - position).normalized() * speed * delta
		move(move_vec)
