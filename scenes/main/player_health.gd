extends ProgressBar

var player: Node2D

func _process(delta):
	if player:
		if is_instance_valid(player):
			value = player.get_node("health_bar").value
		else:
			player = null
