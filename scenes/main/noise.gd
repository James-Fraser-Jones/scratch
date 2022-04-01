tool
extends Sprite

export var size: Vector2 = Vector2.ONE * 512

export var pixel_width: int = 512
export var pixel_height: int = 512

export var noise: OpenSimplexNoise
export var noise_offset: Vector2 = Vector2.ZERO
export var noise_size: Vector2 = Vector2.ONE * 512

export var noise_2: OpenSimplexNoise
export var noise_2_offset: Vector2 = Vector2.ZERO
export var noise_2_size: Vector2 = Vector2.ONE * 512

export var noise_3: OpenSimplexNoise
export var noise_3_offset: Vector2 = Vector2.ZERO
export var noise_3_size: Vector2 = Vector2.ONE * 512

export var layers: int = 0
export var raise: float = 0
export var raise_2: float = 0
export var avoid_2: float = 0
export var raise_3: float = 0
export var avoid_3: float = 0

export var seed_offset: int = 0

export var threshold: float = 0
export var threshold_index: float = -2

export var generate: bool setget run_generate
export var delete: bool setget run_delete
export var test: bool setget run_test

var noise_grid: Array = []

func run_test(_b):
	if Engine.is_editor_hint():
		pass

func run_generate(_b):
	if Engine.is_editor_hint():
		scale = size / Vector2(pixel_width, pixel_height)
		
		var results = get_noise_grid(pixel_width, pixel_height, noise, noise_size, noise_offset, seed_offset, true)
		noise_grid = results.noise_grid
		correct_range(noise_grid, results.min_sample, results.max_sample)
		raise_grid(noise_grid, raise)
		
		if layers > 0:
			results = get_noise_grid(pixel_width, pixel_height, noise_2, noise_2_size, noise_2_offset, seed_offset, true)
			var noise_grid_2 = results.noise_grid
			correct_range(noise_grid_2, results.min_sample, results.max_sample)
			raise_grid(noise_grid_2, raise_2)
			avoid_grid(noise_grid_2, noise_grid, avoid_2)
			merge_grids(noise_grid, noise_grid_2)
			
			if layers > 1:
				results = get_noise_grid(pixel_width, pixel_height, noise_3, noise_3_size, noise_3_offset, seed_offset, true)
				var noise_grid_3 = results.noise_grid
				correct_range(noise_grid_3, results.min_sample, results.max_sample)
				raise_grid(noise_grid_3, raise_3)
				avoid_grid(noise_grid_3, noise_grid, avoid_3)
				merge_grids(noise_grid, noise_grid_3)
		
		var threshold_grid = get_threshold_grid(noise_grid, threshold, threshold_index)
		
		var img = Image.new()
		img.create(pixel_width, pixel_height, false, Image.FORMAT_RGB8)
		img.lock()
		for j in pixel_height:
			for i in pixel_width:
				var sample = threshold_grid[j][i]
				if sample == threshold_index:
					img.set_pixel(i, j, Color.red)
				else:
					img.set_pixel(i, j, Color.from_hsv(0, 0, (sample + 1)/2))
		img.unlock()
		
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		#tex.flags = ...
		texture = tex

func run_delete(_b):
	if Engine.is_editor_hint():
		texture = null

##################################################################

func get_noise_grid(pixel_width: int, pixel_height: int, noise: OpenSimplexNoise, noise_size: Vector2, noise_offset: Vector2, seed_offset: int, find_range: bool) -> Dictionary:
	noise.seed += seed_offset
	var min_sample = 0
	var max_sample = 0
	var noise_grid = []
	for j in pixel_height:
		var noise_row = []
		for i in pixel_width:
			var coord = Vector2(i, j) * noise_size / Vector2(pixel_width-1, pixel_height-1) + noise_offset
			var sample = noise.get_noise_2dv(coord)
			if find_range:
				min_sample = min(min_sample, sample)
				max_sample = max(max_sample, sample)
			noise_row.append(sample)
		noise_grid.append(noise_row)
	noise.seed -= seed_offset
	var results = {"noise_grid" : noise_grid, "min_sample" : min_sample, "max_sample" : max_sample}
	return results

func correct_range(noise_grid: Array, min_sample: float, max_sample: float):
	for j in noise_grid.size():
		for i in noise_grid[0].size():
			var current = noise_grid[j][i]
			noise_grid[j][i] = lerp_solver(min_sample, max_sample, -1, 1, current)
			
func avoid_grid(noise_grid: Array, avoid_grid: Array, avoid_ratio: float):
	for j in noise_grid.size():
		for i in noise_grid[0].size():
			var current = noise_grid[j][i]
			var avoid = avoid_grid[j][i]
			noise_grid[j][i] = clamp(current - lerp_solver(-1, 1, -2*avoid_ratio, 0, avoid), -1, 1)

func merge_grids(lower_grid: Array, upper_grid: Array):
	for j in lower_grid.size():
		for i in lower_grid[0].size():
			var u = upper_grid[j][i]
			var l = lower_grid[j][i]
			lower_grid[j][i] = min(u, l)

func raise_grid(noise_grid: Array, raise_val: float):
	for j in noise_grid.size():
		for i in noise_grid[0].size():
			var sample = noise_grid[j][i]
			noise_grid[j][i] = clamp(sample + raise_val, -1, 1)

func get_threshold_grid(noise_grid: Array, threshold: float, replacement: float) -> Array:
	var threshold_grid = []
	for j in noise_grid.size():
		var threshold_row = []
		for i in noise_grid[0].size():
			var sample = noise_grid[j][i]
			if sample <= threshold:
				threshold_row.append(replacement)
			else:
				threshold_row.append(sample)
		threshold_grid.append(threshold_row)
	return threshold_grid

##################################################################

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y
