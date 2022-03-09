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

export var generate: bool setget run_generate
export var delete: bool setget run_delete

func run_generate(_b):
	if Engine.is_editor_hint():
		scale = size / Vector2(pixel_width, pixel_height)
		
		var results
		
		results = get_noise_grid(pixel_width, pixel_height, noise, noise_size, noise_offset, true)
		var noise_grid = results.noise_grid
		correct_range(noise_grid, results.min_sample, results.max_sample)
		raise_grid(noise_grid, raise)
		
		if layers > 0:
			results = get_noise_grid(pixel_width, pixel_height, noise_2, noise_2_size, noise_2_offset, true)
			var noise_grid_2 = results.noise_grid
			correct_range(noise_grid_2, results.min_sample, results.max_sample)
			
			raise_grid(noise_grid_2, raise_2)
			avoid_grid(noise_grid_2, noise_grid, avoid_2)
			merge_grids(noise_grid, noise_grid_2)
			
			if layers > 1:
				results = get_noise_grid(pixel_width, pixel_height, noise_3, noise_3_size, noise_3_offset, true)
				var noise_grid_3 = results.noise_grid
				correct_range(noise_grid_3, results.min_sample, results.max_sample)
				
				raise_grid(noise_grid_3, raise_3)
				avoid_grid(noise_grid_3, noise_grid, avoid_3)
				merge_grids(noise_grid, noise_grid_3)
		
		threshold_grid(noise_grid, 0, -2)
		
		var img = Image.new()
		img.create(pixel_width, pixel_height, false, Image.FORMAT_RGB8)
		img.lock()
		for j in pixel_height:
			for i in pixel_width:
				var sample = noise_grid[j][i]
				if sample == -2:
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

func get_noise_grid(pixel_width: int, pixel_height: int, noise: OpenSimplexNoise, noise_size: Vector2, noise_offset: Vector2, find_range: bool) -> Dictionary:
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

func threshold_grid(noise_grid: Array, threshold: float, replacement: float):
	for j in noise_grid.size():
		for i in noise_grid[0].size():
			var sample = noise_grid[j][i]
			if sample <= threshold:
				noise_grid[j][i] = replacement

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y

##################################################################

func merge_grids_1(lower, upper) -> Array:
	var noise_grid = []
	for j in pixel_height:
		var noise_row = []
		for i in pixel_width:
			var u = upper[j][i]
			var l = lower[j][i]
			if l <= -1:
				noise_row.append(l)
			else:
				noise_row.append(u)
		noise_grid.append(noise_row)
	return noise_grid

func get_noise_grid_1(add_threshold: bool, range_correction: bool, threshold: float) -> Array:
	var min_sample = 0
	var max_sample = 0
	
	var noise_grid = []
	for j in pixel_height:
		var noise_row = []
		for i in pixel_width:
			var coord = Vector2(i, j) * noise_size / Vector2(pixel_width-1, pixel_height-1) + noise_offset
			var sample = noise.get_noise_2dv(coord)
			if range_correction:
				min_sample = min(min_sample, sample)
				max_sample = max(max_sample, sample)
			noise_row.append(sample)
		noise_grid.append(noise_row)
		
	if range_correction:
		for j in pixel_height:
			for i in pixel_width:
				var current = noise_grid[j][i]
				noise_grid[j][i] = lerp_solver(min_sample, max_sample, -1, 1, current)
	
	if add_threshold:
		for j in pixel_height:
			for i in pixel_width:
				var current = noise_grid[j][i]
				if current <= threshold:
					noise_grid[j][i] = -2
	
	return noise_grid

func get_noise_grid_2(thresholds: Array, thresh_index: int) -> Array:
	var temp_period = noise.period
	noise.period = noise.period * thresholds[thresh_index].period_scale
	
	var min_sample = 0
	var max_sample = 0
	
	var noise_grid = []
	for j in pixel_height:
		var noise_row = []
		for i in pixel_width:
			var coord = Vector2(i, j) * noise_size / Vector2(pixel_width-1, pixel_height-1) + noise_offset
			var sample = noise.get_noise_2dv(coord)
			min_sample = min(min_sample, sample)
			max_sample = max(max_sample, sample)
			noise_row.append(sample)
		noise_grid.append(noise_row)
		
	for j in pixel_height:
		for i in pixel_width:
			var current = noise_grid[j][i]
			noise_grid[j][i] = lerp_solver(min_sample, max_sample, -1, 1, current)
	
	for j in pixel_height:
		for i in pixel_width:
			var current = noise_grid[j][i]
			if current <= thresholds[thresh_index].threshold:
				noise_grid[j][i] = thresholds[thresh_index].index
	
	noise.period = temp_period
	return noise_grid

func avoid_grid_1(noise_grid: Array, avoid_grid: Array, avoid_ratio: float):
	for j in noise_grid.size():
		for i in noise_grid[0].size():
			var current = noise_grid[j][i]
			var avoid = avoid_grid[j][i]
			noise_grid[j][i] = current * (1 - avoid_ratio) - avoid * avoid_ratio
