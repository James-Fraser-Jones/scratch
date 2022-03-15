extends Sprite

export var size: Vector2 = Vector2.ONE * 512

export var pixel_width: int = 512
export var pixel_height: int = 512

export var value: float = 0.5
export var alpha: float = 0.5

export var vision_radius: float = 4096

var player: Node2D
var pixel_radius: int

func _ready():
	calc_pixel_radius()
	generate_fog()

func _physics_process(delta):
	if player:
		if is_instance_valid(player):
			unfog(player.position)
		else:
			player = null

func unfog(player_pos):
	var pixel_pos = get_pixel_pos(player_pos)
	var img = texture.image
	img.lock()
	for j in range(max(0,pixel_pos.y-pixel_radius), min(pixel_height,pixel_pos.y+pixel_radius+1)):
		for i in range(max(0,pixel_pos.x-pixel_radius), min(pixel_width,pixel_pos.x+pixel_radius+1)):
			var cur_pixel_pos = Vector2(i, j)
			if ((cur_pixel_pos - pixel_pos).length() <= pixel_radius):
				img.set_pixelv(cur_pixel_pos, Color.from_hsv(0,0,0,0))
	img.unlock()
	texture.set_data(img)

func calc_pixel_radius():
	var r = Vector2.ONE * vision_radius / size * Vector2(pixel_width, pixel_height)
	pixel_radius = min(r.x, r.y)

func get_pixel_pos(pos: Vector2) -> Vector2:
	var pixel_pos = (pos + size/2) / size * Vector2(pixel_width, pixel_height)
	pixel_pos = Vector2(clamp(pixel_pos.x, 0, pixel_width-1), clamp(pixel_pos.y, 0, pixel_height-1))
	return pixel_pos

func generate_fog():
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
