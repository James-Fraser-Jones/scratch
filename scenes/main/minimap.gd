extends Node2D

export var cam_path : NodePath
export var map_path : NodePath

export var icon_color : Color = Color.green
export var icon_radius : float = 1

export var box_color : Color = Color.red
export var box_width : float = 1

export var terrain_color : Color = Color.blue

export var fog_pixel_width: int = 512
export var fog_pixel_height: int = 512
export var fog_value: float = 0.1
export var fog_alpha: float = 0.95

var cam : Node2D
var map : Node2D

var cam_dim : Vector2
var cam_zoom : Vector2 = Vector2.ONE

func _ready():
	map = get_node(map_path)
	cam = get_node(cam_path)
	cam_dim = $"/root".get_viewport().size
	var viewport = get_parent()
	var viewport_cont = viewport.get_parent()
	$icon.color = icon_color
	$icon.radius = icon_radius
	$box.color = box_color
	$box.width = box_width
	$cam.zoom = map.size / viewport.size
	#viewport_cont.rect_size = viewport.size
	copy_map()
	generate_fog()

func _physics_process(delta):
	$icon.position = cam.position
	$box.position = cam.position
	
	if cam_zoom != cam.zoom:
		cam_zoom = cam.zoom
		$box.size = cam_dim * cam_zoom
	
	var tl = get_pixel_pos(cam.position - cam_dim/2 * cam_zoom)
	var br = get_pixel_pos(cam.position + cam_dim/2 * cam_zoom)
	
	var img = $fog.texture.image
	img.lock()
	for j in range(tl.y, br.y+1):
		for i in range(tl.x, br.x+1):
			img.set_pixel(i, j, Color.from_hsv(0,0,0,0))
	img.unlock()
	$fog.texture.set_data(img)

############################################################

func copy_map():
	for col_poly in map.get_child(0).get_children():
		$map.add_child(make_polygon(col_poly))

func make_polygon(col_poly: CollisionPolygon2D) -> Polygon2D:
	var poly = Polygon2D.new()
	poly.polygon = col_poly.polygon
	poly.color = terrain_color
	return poly

############################################################
	
func get_pixel_pos(pos: Vector2) -> Vector2:
	var pixel_pos = (pos + map.size/2) / map.size * Vector2(fog_pixel_width, fog_pixel_height)
	pixel_pos = Vector2(clamp(pixel_pos.x, 0, fog_pixel_width-1), clamp(pixel_pos.y, 0, fog_pixel_height-1))
	return pixel_pos

func generate_fog():
	$fog.scale = map.size / Vector2(fog_pixel_width, fog_pixel_height)
	
	var img = Image.new()
	img.create(fog_pixel_width, fog_pixel_height, false, Image.FORMAT_RGBA8)
	img.lock()
	for j in fog_pixel_height:
		for i in fog_pixel_width:
			img.set_pixel(i, j, Color.from_hsv(0, 0, fog_value, fog_alpha))
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	#tex.flags = ...
	
	$fog.texture = tex
