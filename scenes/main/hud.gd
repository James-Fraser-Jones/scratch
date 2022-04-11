extends CanvasLayer

func _process(delta):
	$fps.text = "FPS: " + str(Engine.get_frames_per_second())
	$enemies.text = "Enemies: " + str(get_tree().get_nodes_in_group("enemies").size())
	$bullets.text = "Bullets: " + str(get_tree().get_nodes_in_group("bullets").size())
