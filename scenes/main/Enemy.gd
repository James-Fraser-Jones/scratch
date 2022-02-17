extends KinematicBody2D

var health : int = 100

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()

#func _physics_process(delta):
#	move_and_collide(Vector2.LEFT * 15)
