extends Camera2D

export var follow_path: NodePath = ""

var follow: Node2D

func _ready():
	if follow_path:
		follow = get_node(follow_path)

func _physics_process(delta):
	if follow:
		if is_instance_valid(follow):
			position = follow.position
		else:
			follow = null
