extends "res://scenes/character/character.gd"

export var nav_freq : float = 2
export var col_max : float = 40
export var col_radius : float = 150
export var cull_zone : float = 0.2

onready var nav : Navigation2D = $"/root/main/nav"

var nav_path : PoolVector2Array
var nav_cur : float = -1

func nav_timer(delta):
	if nav_cur >= 0:
		nav_cur += delta
		if nav_cur > 1/nav_freq:
			nav_cur = -1

func avoid():
	var space_state = get_world_2d().direct_space_state
	var u = test_dir(space_state, Vector2( 0, -1))
	var d = test_dir(space_state, Vector2( 0,  1))
	var l = test_dir(space_state, Vector2(-1,  0))
	var r = test_dir(space_state, Vector2( 1,  0))
	var ul = test_dir(space_state, Vector2(-1, -1))
	var ur = test_dir(space_state, Vector2( 1, -1))
	var dl = test_dir(space_state, Vector2(-1,  1))
	var dr = test_dir(space_state, Vector2( 1,  1))
	
	var avoid_vec = Vector2.ZERO
	avoid_vec += u
	avoid_vec += d
	avoid_vec += l
	avoid_vec += r
	avoid_vec += ul
	avoid_vec += ur
	avoid_vec += dl
	avoid_vec += dr
	
	if avoid_vec.length() > 1:
		avoid_vec = avoid_vec.normalized()
	elif avoid_vec.length() < cull_zone:
		avoid_vec = Vector2.ZERO
		
	return avoid_vec

func test_dir(space_state, dir : Vector2) -> Vector2:
	var result = space_state.intersect_ray(global_position, global_position + dir.normalized() * col_radius, [self])
	if result:
		var dist = (result.position - global_position).length()
		return -dir * scale_response(dist)
	return Vector2.ZERO
		
func scale_response(dist):
	var response = min(1, dist / (col_max-col_radius) + (col_radius/(col_radius-col_max)))
	return response

func _physics_process(delta):
	nav_timer(delta)
	
	if get_tree().has_group("players"):
		var player = get_tree().get_nodes_in_group("players")[0]
		
		var look_vec = player.position - position
		set_rot(look_vec.angle())
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, player.position, get_tree().get_nodes_in_group("enemies"))
		if result and result.collider == player:
			$gun.shoot(look_vec)
		
		if nav_cur == -1:
			nav_path = nav.get_simple_path(position, player.position)
		
		if nav_path.size() > 0:
			var nav_pos = nav_path[0]
			if position == nav_pos:
				nav_path.remove(0)
				nav_pos	= nav_path[0]
				
			var move_quota = speed * delta
			var goal_vec = (nav_pos - position).normalized()
			var avoid_vec = avoid()
			#print(rad2deg(avoid_vec.angle()))
			var move_vec = avoid_vec + goal_vec * (1 - avoid_vec.length())
			move(move_vec * move_quota)
