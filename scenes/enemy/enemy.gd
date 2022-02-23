extends KinematicBody2D

export var max_health : int = 100
export var speed : int = 350

var health : int = max_health

var nav : Navigation2D

func _ready():
	nav = $"/root/main/nav"

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
	if get_tree().has_group("players"):
		var player = get_tree().get_nodes_in_group("players")[0]
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, player.position, [self])
		if result and result.collider == player:
			var shoot_vec = player.position - position
			$gun.shoot(shoot_vec)
		
		var nav_pos = nav.get_simple_path(position, player.position)[1]
		var move_vec = (nav_pos - position).normalized() * speed * delta
		move(move_vec)
