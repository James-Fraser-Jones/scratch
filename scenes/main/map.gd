tool
extends StaticBody2D

enum DIAG {FALSE = 0, AVERAGE = 1, TRUE = 2}
enum DIR {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}

export var noise: OpenSimplexNoise = OpenSimplexNoise.new()

export var cols: int = 10
export var rows: int = 10
export var threshold: float = 0
export var diag: int = DIAG.AVERAGE
export var interp: bool = true
export var middle: bool = true
export var only_edges: bool = true

export var generate: bool setget run_generate
export var delete: bool setget run_delete

const lookup_table = [ #first edge is always cell-cutting, all vertices traversed anti-clockwise
	[],
	[[Vector2(1,2),Vector2(0,1),Vector2(0,2)]],
	[[Vector2(2,1),Vector2(1,2),Vector2(2,2)]],
	[[Vector2(2,1),Vector2(0,1),Vector2(0,2),Vector2(2,2)]],
	
	[[Vector2(1,0),Vector2(2,1),Vector2(2,0)]],
	[[Vector2(1,2),Vector2(0,1),Vector2(0,2)],[Vector2(1,0),Vector2(2,1),Vector2(2,0)]],
	[[Vector2(1,0),Vector2(1,2),Vector2(2,2),Vector2(2,0)]],
	[[Vector2(1,0),Vector2(0,1),Vector2(0,2),Vector2(2,2),Vector2(2,0)]],
	
	[[Vector2(0,1),Vector2(1,0),Vector2(0,0)]],
	[[Vector2(1,2),Vector2(1,0),Vector2(0,0),Vector2(0,2)]],
	[[Vector2(0,1),Vector2(1,0),Vector2(0,0)],[Vector2(2,1),Vector2(1,2),Vector2(2,2)]],
	[[Vector2(2,1),Vector2(1,0),Vector2(0,0),Vector2(0,2),Vector2(2,2)]],
	
	[[Vector2(0,1),Vector2(2,1),Vector2(2,0),Vector2(0,0)]],
	[[Vector2(1,2),Vector2(2,1),Vector2(2,0),Vector2(0,0),Vector2(0,2)]],
	[[Vector2(0,1),Vector2(1,2),Vector2(2,2),Vector2(2,0),Vector2(0,0)]],
	[[Vector2(0,0),Vector2(0,2),Vector2(2,2),Vector2(2,0)]],
	
	[[Vector2(1,0),Vector2(0,1),Vector2(0,2), Vector2(1,2),Vector2(2,1),Vector2(2,0)]], 
	[[Vector2(2,1),Vector2(1,0),Vector2(0,0), Vector2(0,1),Vector2(1,2),Vector2(2,2)]],
]

func run_generate(_b):
	if Engine.is_editor_hint():
		remove_all_children()
		var noise_grid = get_noise_grid(rows+1, cols+1, noise)
		border_noise_grid(rows+1, cols+1, -1, noise_grid)
		var lookup_grid = get_lookup_grid(rows, cols, noise_grid, threshold)
		do_the_rest(lookup_grid, noise_grid)
		
func run_delete(_b):
	if Engine.is_editor_hint():
		remove_all_children()

func do_the_rest(lookup_grid, noise_grid):
	var edges = []
	for j in range(0, lookup_grid.size()):
		for i in range(0, lookup_grid[0].size()):
			var lookup_val = lookup_grid[j][i]
			var polygons = lookup_table[lookup_val]
			for polygon in polygons:
				var poly = shallow_copy_array(polygon)
				var translate = Vector2(i, j) * 2
				for p in range(0, poly.size()):
					if interp: #perform interpolation
						if poly[p].x == 1:
							var l = noise_grid[j + poly[p].y/2][i]
							var r = noise_grid[j + poly[p].y/2][i+1]
							poly[p].x = lerp_finder(l, r, 0, 2, threshold)
						elif poly[p].y == 1:
							var t = noise_grid[j][i + poly[p].x/2]
							var b = noise_grid[j+1][i + poly[p].x/2]
							poly[p].y = lerp_finder(t, b, 0, 2, threshold)
					poly[p] += translate
				if !only_edges:
					add_convex(poly)
				else:
					edges.append([poly[0], poly[1]])
					if poly.size() == 6:
						edges.append([poly[4], poly[5]])
	if only_edges:
		traverse_edges(edges)

func traverse_edges(edges: Array):
	while (edges.size() > 0):
		var points: Array = edges.pop_back()
		var first_point = points[0]
		var last_point = points[1]
		while (last_point != first_point):
			for i in range(0, edges.size()):
				var edge = edges[i]
				if edge[0] == last_point:
					points.append(edge[1])
					last_point = edge[1]
					edges.remove(i)
					break
				elif edge[1] == last_point:
					points.append(edge[0])
					last_point = edge[0]
					edges.remove(i)
					break
		points.pop_back()
		add_poly(points)		

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
	for j in range (0, rows):
		var lookup_row = []
		for i in range(0, cols):
			var tl = grid[j][i]
			var tr = grid[j][i+1]
			var bl = grid[j+1][i]
			var br = grid[j+1][i+1]
			var lookup_val = get_lookup_val(tl, tr, bl, br, threshold)
			if lookup_val == 5 or lookup_val == 10: #handle ambiguous cases
				match diag:
					DIAG.TRUE:
						lookup_val = fill_middle(lookup_val)
					DIAG.FALSE:
						pass
					DIAG.AVERAGE:
						var avg = (tl + tr + bl + br)/4
						if avg > threshold:
							lookup_val = fill_middle(lookup_val)
			elif lookup_val == 15:
				if !middle or only_edges:
					lookup_val = 0
			lookup_row.append(lookup_val)
		lookup_grid.append(lookup_row)
	return lookup_grid

func fill_middle(val: int) -> int:
	var filled
	if val == 5:
		filled = 16 
	else: #val == 10
		filled = 17
	return filled

func get_noise_grid(rows, cols, noise) -> Array:
	var noise_grid = []
	for j in range (0, rows):
		var noise_row = []
		for i in range (0, cols):
			noise_row.append(noise.get_noise_2d(i, j))
		noise_grid.append(noise_row)
	return noise_grid

func remove_all_children():
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

func add_poly(points):
	if points.size() > 0:
		var col_poly = CollisionPolygon2D.new()
		col_poly.polygon = points
		add_child(col_poly)
		col_poly.owner = get_tree().edited_scene_root #otherwise won't show up in scene tree

func shallow_copy_array(arr):
	var new = []
	for elem in arr:
		new.append(elem)
	return new
