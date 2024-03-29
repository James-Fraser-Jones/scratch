extends Area2D

export var speed : float = 2000
export var max_time : float = 10
export var damage : float = 5

var cur_time : float = 0

func _ready():
	connect("body_entered", self, "_collision")

func _physics_process(delta):
	cur_time += delta
	if cur_time > max_time:
		queue_free()
	position += Vector2.UP.rotated(transform.get_rotation()) * speed * delta

func _collision(body):
	if body.is_in_group("players") or body.is_in_group("enemies"):
		body.hurt(damage)
	queue_free()
