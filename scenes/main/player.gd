extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var bullet_scene = preload("res://scenes/bullet.tscn")

export var speed : int = 500
export var attack_speed : float = 15
export var attack_spread : float = .1

var health : int = 100
var attack_cur : float = -1

var main : Node2D

func _ready():
	rng.randomize()
	main = get_parent()

func _physics_process(delta):
	shoot_timer(delta)
	control(delta)

func shoot_timer(delta):
	if attack_cur >= 0:
		attack_cur += delta
		if attack_cur > 1/attack_speed:
			attack_cur = -1

func hurt(damage):
	health -= damage
	$health_bar.value = health
	if health <= 0:
		queue_free()
		
func shoot(shoot_vec):
	if attack_cur == -1:
		var bullet = bullet_scene.instance()
		var angle = shoot_vec.angle()
		bullet.rotation = angle + PI/2 + rng.randf_range(-attack_spread/2, attack_spread/2)
		bullet.position = position
		bullet.group = "enemies"
		bullet.collision_mask = 5 #walls and enemies
		main.add_child(bullet)
		attack_cur = 0

func move(move_vec):
	var collision = move_and_collide(move_vec)
	if collision:
		move_and_collide(collision.remainder.slide(collision.normal))

func control(delta):
	if Input.is_action_pressed("shoot"):
		var shoot_vec = get_global_mouse_position() - position
		shoot(shoot_vec)
	var move_vec = lrud() * speed * delta
	move(move_vec)

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
