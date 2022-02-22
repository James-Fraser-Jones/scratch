extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("restart"):
		get_tree().change_scene("res://scenes/main/main.tscn")
	if event.is_action_pressed("spawn"):
		var enemy = enemy_scene.instance()
		enemy.position = Vector2(600, 250)
		enemy.add_to_group("enemies")
		add_child(enemy)
