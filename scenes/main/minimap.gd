extends Node2D

export var cam_path : NodePath
export var map_path : NodePath

export var icon_color : Color = Color.green
export var icon_pixel_radius : float = 2

export var box_color : Color = Color.red
export var box_pixel_width : float = 2

export var terrain_color : Color = Color.blue

export var fog_pixel_res: int = 512
export var fog_value: float = 0.1
export var fog_alpha: float = 0.95

export var enabled: bool = false setget enabled_changed

var cam : Node2D
var map : Node2D

var cam_dim : Vector2
var cam_zoom : Vector2 = Vector2.ONE

var map_length : float

func _ready():
	map = get_node(map_path)
	cam = get_node(cam_path)
	
	cam_dim = $"/root".get_viewport().size
	map_length = max(map.size.x, map.size.y)
	
	var scale = map_length / fog_pixel_res
	$icon.color = icon_color
	$icon.radius = icon_pixel_radius * scale
	$box.color = box_color
	$box.width = box_pixel_width * scale
	
	var viewport = get_parent()
	var viewport_length = max(viewport.size.x, viewport.size.y)
	$cam.zoom = Vector2.ONE * map_length / viewport_length
	
	copy_map()
	generate_fog()

func _physics_process(delta):
	if enabled:
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

func enabled_changed(e : bool):
	enabled = e
	$icon.visible = enabled
	$box.visible = enabled

func copy_map():
	for col_poly in map.get_child(0).get_children():
		$map.add_child(make_polygon(col_poly))

func make_polygon(col_poly: CollisionPolygon2D) -> Polygon2D:
	var poly = Polygon2D.new()
	poly.polygon = col_poly.polygon
	poly.color = terrain_color
	return poly
	
func get_pixel_pos(pos: Vector2) -> Vector2:
	var map_size = Vector2.ONE * map_length
	var fog_size = Vector2.ONE * fog_pixel_res
	var pixel_pos = (pos + map_size/2) / map_size * fog_size
	pixel_pos = Vector2(clamp(pixel_pos.x, 0, fog_pixel_res-1), clamp(pixel_pos.y, 0, fog_pixel_res-1))
	return pixel_pos

func generate_fog():
	$fog.scale = Vector2.ONE * map_length / fog_pixel_res
	
	var img = Image.new()
	img.create(fog_pixel_res, fog_pixel_res, false, Image.FORMAT_RGBA8)
	img.lock()
	for j in fog_pixel_res:
		for i in fog_pixel_res:
			img.set_pixel(i, j, Color.from_hsv(0, 0, fog_value, fog_alpha))
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	#tex.flags = ...
	
	$fog.texture = tex
