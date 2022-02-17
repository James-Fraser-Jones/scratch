extends KinematicBody2D

export var speed : float = 15

func _physics_process(delta):
	var collision = move_and_collide(Vector2.UP.rotated(transform.get_rotation()) * speed)
	if collision:
		queue_free()

func _on_HitBox_body_entered(body):
	queue_free()
