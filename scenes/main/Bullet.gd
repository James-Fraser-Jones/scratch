extends Area2D

export var speed : float = 1000

func _physics_process(delta):
	position += Vector2.UP.rotated(transform.get_rotation()) * speed * delta

func _on_bullet_body_entered(body):
	if body.is_in_group("enemies"):
		body.hurt(15)
	queue_free()
