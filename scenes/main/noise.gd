tool
extends Sprite

export var width: int = 512
export var height: int = 512

export var noise: OpenSimplexNoise
export var noise_offset: Vector2 = Vector2.ZERO

export var range_correction: bool = true

export var generate: bool setget run_generate
export var delete: bool setget run_delete

func run_generate(_b):
	if Engine.is_editor_hint():
		var img = Image.new()
		img.create(width, height, false, Image.FORMAT_RGB8)
		
		var minn = 0
		var maxx = 0
					
		img.lock()
		for j in height:
			for i in width:
				var sample = noise.get_noise_2d(i + noise_offset.x, j + noise_offset.y)
				if range_correction:
					minn = min(minn, sample)
					maxx = max(maxx, sample)
				img.set_pixel(i, j, Color.from_hsv(0, 0, (sample + 1)/2))
		img.unlock()
		
		if range_correction:
			img.lock()
			for j in height:
				for i in width:
					var current = img.get_pixel(i, j).v * 2 - 1
					img.set_pixel(i, j, Color.from_hsv(0, 0, lerp_solver(minn, maxx, 0, 1, current)))
			img.unlock()
		
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		#tex.flags = ...
		
		texture = tex

func run_delete(_b):
	if Engine.is_editor_hint():
		texture = null

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y
