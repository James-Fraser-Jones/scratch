extends Node2D

const player_scene = preload("res://scenes/player/player.tscn")
const enemy_scene = preload("res://scenes/enemy/enemy.tscn")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("restart"):
		get_tree().change_scene("res://scenes/main/main.tscn")
		
	if event.is_action_pressed("spawn_enemy"):
		var enemy = enemy_scene.instance()
		enemy.position = Vector2(600, 250)
		enemy.add_to_group("enemies")
		add_child(enemy)
		
	if event.is_action_pressed("spawn_player"):
		if !get_tree().has_group("players"):
			var player = player_scene.instance()
			player.position = Vector2(100, -100)
			player.add_to_group("players")
			add_child(player)
	
