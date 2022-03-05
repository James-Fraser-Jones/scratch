extends Node2D

const player_scene = preload("res://scenes/player/player.tscn")
const enemy_scene = preload("res://scenes/enemy/enemy.tscn")

func _process(delta):
	if get_tree().has_group("players"):
		var player = get_tree().get_nodes_in_group("players")[0]
		$cam.position = player.position

func _ready():
	randomize()

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("restart"):
		get_tree().change_scene("res://scenes/main/main.tscn")
		
	if event.is_action_pressed("spawn_enemy"):
		var enemy = enemy_scene.instance()
		enemy.position = $spawners/enemy.position #Vector2(rand_range(-5000, 5000), rand_range(-5000, 5000)) #(doesn't work because enemies spawn in the wall)
		enemy.add_to_group("enemies")
		add_child(enemy)
		
	if event.is_action_pressed("spawn_player"):
		if !get_tree().has_group("players"):
			var player = player_scene.instance()
			player.position = $spawners/player.position
			player.add_to_group("players")
			add_child(player)
	
	if event.is_action_pressed("zoom_in"):
		$cam.zoom = $cam.zoom / 2
		
	if event.is_action_pressed("zoom_out"):
		$cam.zoom = $cam.zoom * 2
	
