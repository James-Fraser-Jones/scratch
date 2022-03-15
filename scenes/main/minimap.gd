extends Node2D

var follow : Node2D

func _ready():
	for node in $"/root/main/map2/StaticBody2D".get_children():
		$minimap_map.add_child(node.duplicate())

func _physics_process(delta):
	if follow:
		if is_instance_valid(follow):
			$minimap_player.position = follow.position
		else:
			follow = null
