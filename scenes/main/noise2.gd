tool
extends Sprite

################################################

const default_layer : Dictionary = {"period_scale": 1.0, "raise": 0.0, "recede": 0.5}

################################################

export var size: Vector2 = Vector2.ONE * 60000
export var pixel_width: int = 100
export var pixel_height: int = 100
export var threshold: float = 0
export var normalize: bool = true
export var invert: bool = false

export var noise: OpenSimplexNoise

export var layers: Array = [
	default_layer,
]

################################################

var noise_grid: Array = []

################################################

export var add_layer: bool setget run_add_layer 
export var generate: bool setget run_generate
export var delete: bool setget run_delete
export var test: bool setget run_test

func run_add_layer(_b):
	if Engine.is_editor_hint():
		new_layer()

func run_generate(_b):
	if Engine.is_editor_hint():
		if layers.size() > 0:
			scale = size / Vector2(pixel_width, pixel_height)
			
			var top_layer = layers[0]
			noise_grid = get_noise_grid(0, top_layer)
			
			for i in range(1, layers.size()):
				var add_layer = layers[i]
				var add_grid = get_noise_grid(i, add_layer)
				recede_grid(noise_grid, add_grid, add_layer)
				merge_grids(noise_grid, add_grid)
			
			var tex = ImageTexture.new()
			var img = get_image(noise_grid)
			tex.create_from_image(img)
			#tex.flags = ...
			texture = tex

func run_delete(_b):
	if Engine.is_editor_hint():
		texture = null

func run_test(_b):
	if Engine.is_editor_hint():
		pass

################################################

func new_layer():
	layers.append(default_layer)
	property_list_changed_notify()

func get_noise_grid(seed_offset: int, layer: Dictionary, noise_size: Vector2 = Vector2.ONE * 512, noise_offset: Vector2 = Vector2.ZERO) -> Array:
	var t_seed = noise.seed
	var t_period = noise.period
	noise.seed += seed_offset
	noise.period *= layer.period_scale
	
	var min_sample = 0
	var max_sample = 0
	var noise_grid = []
	for j in pixel_height:
		var noise_row = []
		for i in pixel_width:
			var coord = Vector2(i, j) / Vector2(pixel_width-1, pixel_height-1) * noise_size + noise_offset
			var sample = noise.get_noise_2dv(coord)
			if normalize:
				min_sample = min(min_sample, sample)
				max_sample = max(max_sample, sample)
			noise_row.append(sample)
		noise_grid.append(noise_row)
	
	noise.seed = t_seed
	noise.period = t_period
	
	if normalize:
		for j in pixel_height:
			for i in pixel_width:
				var current = noise_grid[j][i]
				noise_grid[j][i] = lerp_solver(min_sample, max_sample, -1, 1, current)
	
	for j in pixel_height:
		for i in pixel_width:
			var sample = noise_grid[j][i]
			noise_grid[j][i] = clamp(sample + layer.raise, -1, 1)
	
	return noise_grid

func get_image(noise_grid: Array) -> Image:
	var img = Image.new()
	img.create(pixel_width, pixel_height, false, Image.FORMAT_RGB8)
	img.lock()
	for j in pixel_height:
		for i in pixel_width:
			var sample = noise_grid[j][i]
			if (sample <= threshold) != invert:
				img.set_pixel(i, j, Color.red)
			else:
				img.set_pixel(i, j, Color.from_hsv(0, 0, (sample + 1)/2))	
	img.unlock()
	return img

func merge_grids(base: Array, add: Array):
	for j in pixel_height:
		for i in pixel_width:
			var b = base[j][i]
			var a = add[j][i]
			base[j][i] = min(b, a)

func recede_grid(base: Array, add: Array, add_layer: Dictionary):
	for j in pixel_height:
		for i in pixel_width:
			var b = base[j][i]
			var critical = lerp_solver(0, 1, threshold, 1, add_layer.recede)
			if b < critical:
				add[j][i] = b

################################################

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y
