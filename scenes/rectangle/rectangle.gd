extends Node2D

export var size : Vector2 = Vector2.ONE setget set_size
export var color : Color = Color.red
export var width : float = 1

func set_size(s):
	size = s
	update()

func _draw():
	draw_rect(Rect2(Vector2.ZERO-size/2, size), color, false, width)
