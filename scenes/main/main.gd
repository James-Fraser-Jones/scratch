extends Node2D

const player_scene = preload("res://scenes/player/player.tscn")
const enemy_scene = preload("res://scenes/enemy/enemy.tscn")

func _ready():
	randomize()

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("restart"):
		get_tree().change_scene("res://scenes/main/main.tscn")
		
	if event.is_action_pressed("spawn_enemy"):
		var enemy = enemy_scene.instance()
		enemy.position = $spawners/enemy.position
		enemy.add_to_group("enemies")
		add_child(enemy)
		
	if event.is_action_pressed("spawn_player"):
		if !get_tree().has_group("players"):
			var player = player_scene.instance()
			player.position = $spawners/player.position
			player.add_to_group("players")
			add_child(player)
			$cam.follow = player
			$hud/player_healthbar.character = player
			$hud/player_healthbar.max_value = player.get_node("health_bar").max_value
			$hud/player_healthbar.value = player.get_node("health_bar").value
	
	if event.is_action_pressed("zoom_in"):
		$cam.zoom = $cam.zoom / 2
		
	if event.is_action_pressed("zoom_out"):
		$cam.zoom = $cam.zoom * 2
	
