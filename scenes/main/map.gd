tool
extends StaticBody2D

export var seeed: int = 0
export var period: float = 64.0

export var octaves: int = 3
export var lacunarity: float = 2.0
export var persistence: float = 0.5

export var gen: bool = false setget run_gen

var noise = OpenSimplexNoise.new()

func run_gen(_b):
	if Engine.is_editor_hint():
		gen_()
		
func gen_():
	for child in get_children():
		child.queue_free()
		
	var col_poly = CollisionPolygon2D.new()
	var poly = PoolVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(0, 100)])
	col_poly.polygon = poly
	
	add_child(col_poly)
	col_poly.owner = get_tree().edited_scene_root #otherwise won't show up in scene tree
	
	#====================================
	
	noise.lacunarity = lacunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.seed = seeed
	
	var grid = []
	for i in range (0, 10):
		var row = []
		for j in range (0, 10):
			row.append(noise.get_noise_2d(i, j))
		grid.append(row)
	print(grid)
	
