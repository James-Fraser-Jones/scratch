extends Node2D

func _process(_delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		get_tree().change_scene("res://scenes/main/main.tscn")
