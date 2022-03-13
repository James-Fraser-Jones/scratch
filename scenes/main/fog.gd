extends Sprite

export var size: Vector2 = Vector2.ONE * 512

export var pixel_width: int = 512
export var pixel_height: int = 512

export var value: float = 0.5
export var alpha: float = 0.5

export var vision_radius: float = 200

var player: Node2D

func _ready():
	gen()

func _process(delta):
	if player:
		if is_instance_valid(player):
			var pixel_pos = get_pixel_pos(player.position)
			if pixel_pos:
				var img = texture.image
				img.lock()
				img.set_pixel(pixel_pos.x, pixel_pos.y, Color.from_hsv(0,0,0,0))
				img.unlock()
				texture.set_data(img)
		else:
			player = null
				
func get_pixel_pos(pos: Vector2) -> Dictionary:
	var pixel_pos = (pos + size/2) / size * Vector2(pixel_width, pixel_height)
	var pixels = {"x": int(pixel_pos.x), "y": int(pixel_pos.y)}
	if pixels.x < 0 or pixels.x >= pixel_width or pixels.y < 0 or pixels.y >= pixel_height:
		return {}
	return pixels

func gen():
	scale = size / Vector2(pixel_width, pixel_height)
		
	var img = Image.new()
	img.create(pixel_width, pixel_height, false, Image.FORMAT_RGBA8)
	img.lock()
	for j in pixel_height:
		for i in pixel_width:
			img.set_pixel(i, j, Color.from_hsv(0, 0, value, alpha))
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	#tex.flags = ...
	
	texture = tex
