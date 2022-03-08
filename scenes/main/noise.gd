tool
extends Sprite

export var size: Vector2 = Vector2.ONE * 512

export var pixel_width: int = 512
export var pixel_height: int = 512

export var noise: OpenSimplexNoise
export var noise_offset: Vector2 = Vector2.ZERO
export var noise_size: Vector2 = Vector2.ONE * 512

export var threshold_num: int = 1
export var thresholds: Array = [
	{"period_scale": 1.0, "threshold": 0.0, "index": -1, "color": Color.red}, 
	{"period_scale": 0.5, "threshold": 0.0, "index": -2, "color": Color.green}, 
	{"period_scale": 0.25, "threshold": 0.0, "index": -3, "color": Color.blue}
]

export var generate: bool setget run_generate
export var delete: bool setget run_delete

func run_generate(_b):
	if Engine.is_editor_hint():
		scale = size / Vector2(pixel_width, pixel_height)
		
		var noise_grid = get_noise_grid(0)
		var temp_seed = noise.seed
		for i in range(1, threshold_num):
			noise.seed += 1
			noise_grid = merge_grids(noise_grid, get_noise_grid(i))
		noise.seed = temp_seed
		
		var img = Image.new()
		img.create(pixel_width, pixel_height, false, Image.FORMAT_RGB8)
		img.lock()
		for j in pixel_height:
			for i in pixel_width:
				var sample = noise_grid[j][i]
				if sample <= -1:
					for entry in thresholds:
						if sample == entry.index:
							img.set_pixel(i, j, entry.color)
							break
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

func merge_grids(lower, upper) -> Array:
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

func get_noise_grid(thresh_index: int) -> Array:
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

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y
