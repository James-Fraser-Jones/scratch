extends KinematicBody2D

export var speed : int = 500

var health : int = 100

#var rng = RandomNumberGenerator.new()
#
#func _init():
#	var HurtTimer = Timer.new()
#	add_child(HurtTimer)
#	HurtTimer.autostart = true
#	HurtTimer.wait_time = 1
#	HurtTimer.connect("timeout", self, "hurt_time")
#
#func _ready():
#	rng.randomize()
#
#func hurt_time():
#	hurt(rng.randi_range(0, 30))

func _process(delta):
	pass

func _physics_process(delta):
	var move : Vector2 = lrud() * speed * delta
	var collision = move_and_collide(move)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))
	
func lrud() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	return input.normalized()

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()
