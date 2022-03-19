extends Node2D

export var radius: float = 1
export var color: Color = Color.green

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
