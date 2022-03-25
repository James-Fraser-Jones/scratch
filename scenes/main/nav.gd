tool
extends Navigation2D

export var map_path: NodePath

export var border_width: float = 1000
export var offset: float = 40
export var circle_res: int = 10
export var circle_res_growth: float = .01
export var merge: bool = true

export var generate: bool setget run_generate
export var delete: bool setget run_delete
export var test: bool setget run_test

func run_test(_b):
	if Engine.is_editor_hint():
		pass

func run_generate(_b):
	if Engine.is_editor_hint() and map_path:
		remove_all_children()
		
		var map = get_node(map_path)
		var outlines = get_outlines(map)
				
		var nav_poly: NavigationPolygon = NavigationPolygon.new()
		for outline in outlines:
			nav_poly.add_outline(outline)
		nav_poly.make_polygons_from_outlines() #fails if "convex partition failed"
		add_instance(nav_poly)

func run_delete(_b):
	if Engine.is_editor_hint():
		remove_all_children()

func get_outlines(map) -> Array:
	var local_offset = offset
	var outlines = []
	
	var bodies = map.get_children()
	for body in bodies:
		var colliders = body.get_children()
		for collider in colliders:
			var poly
			if collider is CollisionPolygon2D:
				poly = collider.polygon
			elif collider is CollisionShape2D:
				var shape = collider.shape
				if shape is RectangleShape2D:
					var ext = shape.extents
					poly = PoolVector2Array([Vector2(-ext.x, -ext.y), Vector2(ext.x, -ext.y), Vector2(ext.x, ext.y), Vector2(-ext.x, ext.y)])
				elif shape is CircleShape2D:
					var rad = shape.radius
					var local_circle_res = max(3, int(circle_res * rad * circle_res_growth))
					local_offset = (offset + rad)/cos(PI / local_circle_res) - rad #https://en.wikipedia.org/wiki/Apothem
					poly = PoolVector2Array()
					for i in range(0, local_circle_res):
						poly.push_back((Vector2.UP*rad).rotated(i * (2 * PI)/local_circle_res))
				else:
					continue
			else:
				continue
				
			for i in range(0, poly.size()):
				var temp = poly[i].rotated(collider.rotation) + collider.position
				poly.set(i, temp.rotated(body.rotation) + body.position)
				
			var new_poly = Geometry.offset_polygon_2d(poly, local_offset, Geometry.JOIN_MITER)[0]
			outlines.append(new_poly)
	
	if merge:
		merge_outlines(outlines)
	
	var size = map.size + Vector2.ONE * border_width
	var outer_points = PoolVector2Array([-size/2, Vector2(size.x, -size.y)/2, size/2, Vector2(-size.x, size.y)/2])
	outlines.append(outer_points)
	
	return outlines

func merge_outlines(outlines):
	var i = 0
	while i < outlines.size():
		var j = 0
		while j < outlines.size():
			if j != i:
				if Geometry.intersect_polygons_2d(outlines[i], outlines[j]).size() > 0:
					var merge = Geometry.merge_polygons_2d(outlines[i], outlines[j])
					if merge.size() == 0:
						outlines.remove(i)
						outlines.remove(j)
					elif merge.size() == 1:
						outlines[i] = merge[0]
						outlines.remove(j)
					elif merge.size() == 2:
						outlines[i] = merge[0]
						outlines[j] = merge[1]
					elif merge.size() > 2:
						outlines[i] = merge[0]
						outlines[j] = merge[1]
						for k in range(2, merge.size()):
							outlines.append(merge[k])
					j = 0
			j += 1
		i += 1

func add_instance(navpoly):
	var inst = NavigationPolygonInstance.new()
	inst.navpoly = navpoly
	add_child(inst)
	inst.owner = get_tree().edited_scene_root #otherwise won't show up in scene tree

func remove_all_children():
	for child in get_children():
		child.queue_free()
