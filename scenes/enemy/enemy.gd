extends "res://scenes/character/character.gd"

onready var nav : Navigation2D = $"/root/main/nav"

func _physics_process(delta):
	if get_tree().has_group("players"):
		var player = get_tree().get_nodes_in_group("players")[0]
		
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, player.position, [self])
		if result and result.collider == player:
			var shoot_vec = player.position - position
			$gun.shoot(shoot_vec)
		
		var path = nav.get_simple_path(position, player.position)
		if path.size() > 1:
			var nav_pos = path[1]
			var move_vec = (nav_pos - position).normalized() * speed * delta
			move(move_vec)
