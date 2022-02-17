extends KinematicBody2D

var health : int = 100

func hurt(damage):
	health -= damage
	$HealthBar.value = health
	if health <= 0:
		queue_free()

func _on_HitBox_body_entered(body):
	hurt(15)

#func _physics_process(delta):
#	move_and_collide(Vector2.LEFT * 15)
