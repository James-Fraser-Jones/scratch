tool
extends StaticBody2D

export var seeed: int = 0
export var period: float = 64.0

export var octaves: int = 3
export var lacunarity: float = 2.0
export var persistence: float = 0.5

export var cols: int = 10
export var rows: int = 10
export var threshold: float = 0

export var gen: bool = false setget run_gen

var noise = OpenSimplexNoise.new()

const lookup = [
	[],
	[Vector2(0,1),Vector2(1,2),Vector2(0,2)],
	[Vector2(2,1),Vector2(1,2),Vector2(2,2)],
	[Vector2(0,1),Vector2(2,1),Vector2(2,2),Vector2(0,2)],
	
	[Vector2(2,0),Vector2(2,1),Vector2(1,0)],
	[Vector2(0,2),Vector2(0,1),Vector2(1,0),Vector2(2,0),Vector2(2,1),Vector2(1,2)],
	[Vector2(1,0),Vector2(2,0),Vector2(2,2),Vector2(1,2)],
	[Vector2(1,0),Vector2(2,0),Vector2(2,2),Vector2(0,2),Vector2(0,1)],
	
	[Vector2(0,0),Vector2(1,0),Vector2(0,1)],
	[Vector2(0,0),Vector2(1,0),Vector2(1,2),Vector2(0,2)],
	[Vector2(0,0),Vector2(1,0),Vector2(2,1),Vector2(2,2),Vector2(1,2),Vector2(0,1)],
	[Vector2(0,0),Vector2(1,0),Vector2(2,1),Vector2(2,2),Vector2(0,2)],
	
	[Vector2(0,0),Vector2(2,0),Vector2(2,1),Vector2(0,1)],
	[Vector2(0,0),Vector2(2,0),Vector2(2,1),Vector2(1,2),Vector2(0,2)],
	[Vector2(0,0),Vector2(2,0),Vector2(2,2),Vector2(1,2),Vector2(0,1)],
	[Vector2(0,0),Vector2(2,0),Vector2(2,2),Vector2(0,2)],
]

func run_gen(_b):
	if Engine.is_editor_hint():
		gen_()
		
func gen_():
	update_noise_params()
	remove_all_convex()
	var noise_grid = get_noise_grid(rows+1, cols+1, noise)
	var lookup_grid = get_lookup_grid(rows, cols, noise_grid, threshold)
	add_from_lookup_grid(lookup_grid)
	
func add_from_lookup_grid(lookup_grid):
	for i in range(0, lookup_grid.size()):
		for j in range(0, lookup_grid[0].size()):
			var points = shallow_copy_array(lookup[lookup_grid[i][j]])
			var translate = Vector2(i, j) * 2
			for k in range(0, points.size()):
				points[k] += translate
			add_convex(points)

func update_noise_params():
	noise.lacunarity = lacunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.seed = seeed

func get_lookup_val(tl, tr, bl, br, threshold) -> int:
	var acc = 0
	acc += int(tl > threshold)
	acc *= 2
	acc += int(tr > threshold)
	acc *= 2
	acc += int(br > threshold)
	acc *= 2
	acc += int(bl > threshold)
	return acc

func get_lookup_grid(rows, cols, grid, threshold) -> Array:
	var lookup_grid = []
	for i in range(0, cols):
		var lookup_row = []
		for j in range (0, rows):
			var tl = grid[i][j]
			var tr = grid[i+1][j]
			var bl = grid[i][j+1]
			var br = grid[i+1][j+1]
			lookup_row.append(get_lookup_val(tl, tr, bl, br, threshold))
		lookup_grid.append(lookup_row)
	return lookup_grid

func get_noise_grid(rows, cols, noise) -> Array:
	var noise_grid = []
	for i in range (0, cols):
		var noise_row = []
		for j in range (0, rows):
			noise_row.append(noise.get_noise_2d(i, j))
		noise_grid.append(noise_row)
	return noise_grid

func remove_all_convex():
	for child in get_children():
		child.queue_free()

func add_convex(points):
	if points.size() > 0:
		var con_shape = ConvexPolygonShape2D.new()
		con_shape.points = PoolVector2Array(points)
		var col_shape = CollisionShape2D.new()
		col_shape.shape = con_shape
		add_child(col_shape)
		col_shape.owner = get_tree().edited_scene_root #otherwise won't show up in scene tree

func shallow_copy_array(arr):
	var new = []
	for elem in arr:
		new.append(elem)
	return new
