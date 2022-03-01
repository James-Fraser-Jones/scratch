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
export var diag: bool = false
export var interp: bool = true

export var generate: bool setget run_generate
export var delete: bool setget run_delete

var noise = OpenSimplexNoise.new()

const lookup_table = [
	[],
	[[Vector2(0,1),Vector2(1,2),Vector2(0,2)]],
	[[Vector2(2,1),Vector2(1,2),Vector2(2,2)]],
	[[Vector2(0,1),Vector2(2,1),Vector2(2,2),Vector2(0,2)]],
	
	[[Vector2(2,0),Vector2(2,1),Vector2(1,0)]],
	[[Vector2(0,2),Vector2(0,1),Vector2(1,0),Vector2(2,0),Vector2(2,1),Vector2(1,2)]], #5. ambiguous (center filled)
	[[Vector2(1,0),Vector2(2,0),Vector2(2,2),Vector2(1,2)]],
	[[Vector2(1,0),Vector2(2,0),Vector2(2,2),Vector2(0,2),Vector2(0,1)]],
	
	[[Vector2(0,0),Vector2(1,0),Vector2(0,1)]],
	[[Vector2(0,0),Vector2(1,0),Vector2(1,2),Vector2(0,2)]],
	[[Vector2(0,0),Vector2(1,0),Vector2(2,1),Vector2(2,2),Vector2(1,2),Vector2(0,1)]], #10. ambiguous (center filled)
	[[Vector2(0,0),Vector2(1,0),Vector2(2,1),Vector2(2,2),Vector2(0,2)]],
	
	[[Vector2(0,0),Vector2(2,0),Vector2(2,1),Vector2(0,1)]],
	[[Vector2(0,0),Vector2(2,0),Vector2(2,1),Vector2(1,2),Vector2(0,2)]],
	[[Vector2(0,0),Vector2(2,0),Vector2(2,2),Vector2(1,2),Vector2(0,1)]],
	[[Vector2(0,0),Vector2(2,0),Vector2(2,2),Vector2(0,2)]],
	
	#16 17. missing ambiguous cases (center unfilled)
	[[Vector2(0,2),Vector2(0,1),Vector2(1,2)],[Vector2(2,0),Vector2(2,1),Vector2(1,0)]],
	[[Vector2(0,0),Vector2(1,0),Vector2(0,1)],[Vector2(2,2),Vector2(1,2),Vector2(2,1)]],
]

func run_generate(_b):
	if Engine.is_editor_hint():
		update_noise_params()
		remove_all_convex()
		var noise_grid = get_noise_grid(rows+1, cols+1, noise)
		border_noise_grid(rows+1, cols+1, -1, noise_grid)
		var lookup_grid = get_lookup_grid(rows, cols, noise_grid, threshold)
		add_from_lookup_grid(lookup_grid, noise_grid)
		
func run_delete(_b):
	if Engine.is_editor_hint():
		remove_all_convex()
	
func add_from_lookup_grid(lookup_grid, noise_grid):
	for j in range(0, lookup_grid.size()):
		for i in range(0, lookup_grid[0].size()):
			var lookup_val = lookup_grid[j][i]
			var point_sets = lookup_table[lookup_val]
			for point_set in point_sets:
				var points = shallow_copy_array(point_set)
				var translate = Vector2(i, j) * 2
				for p in range(0, points.size()):
					if interp:
						if points[p].x == 1:
							var l = noise_grid[j + points[p].y/2][i]
							var r = noise_grid[j + points[p].y/2][i+1]
							points[p].x = lerp_finder(l, r, 0, 2, threshold)
						elif points[p].y == 1:
							var t = noise_grid[j][i + points[p].x/2]
							var b = noise_grid[j+1][i + points[p].x/2]
							points[p].y = lerp_finder(t, b, 0, 2, threshold)
					points[p] += translate
				add_convex(points)

func lerp_finder(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y

func border_noise_grid(rows, cols, val, noise_grid):
	for j in range(0, rows):
		noise_grid[j][0] = val
		noise_grid[j][cols-1] = val
	for i in range(0, cols):
		noise_grid[0][i] = val
		noise_grid[rows-1][i] = val

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
	if !diag:
		if acc == 5:
			acc = 16
		elif acc == 10:
			acc = 17
	return acc

func get_lookup_grid(rows, cols, grid, threshold) -> Array:
	var lookup_grid = []
	for j in range (0, rows):
		var lookup_row = []
		for i in range(0, cols):
			var tl = grid[j][i]
			var tr = grid[j][i+1]
			var bl = grid[j+1][i]
			var br = grid[j+1][i+1]
			lookup_row.append(get_lookup_val(tl, tr, bl, br, threshold))
		lookup_grid.append(lookup_row)
	return lookup_grid

func get_noise_grid(rows, cols, noise) -> Array:
	var noise_grid = []
	for j in range (0, rows):
		var noise_row = []
		for i in range (0, cols):
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

#things missing:
#dealing with ambiguous cases (currently just toggled with bool) https://www.boristhebrave.com/2022/01/03/resolving-ambiguities-in-marching-squares/
#using only a single collision shape per contiguous chunk from thresholded noise function (I think we might need some kind of mesh simplification algorithm)
