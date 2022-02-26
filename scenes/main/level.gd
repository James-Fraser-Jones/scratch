tool
extends Node2D

export var size: Vector2 = Vector2(2048, 1200)
export var offset: float = 45
export var circle_res: int = 10
export var circle_res_growth: float = .01
export var target: NodePath
export var bake: bool = false setget run_bake

func run_bake(_b):
	if Engine.is_editor_hint():
		bake_()

func bake_() -> void:
	if target:
		var local_offset = offset
		var outlines = []
		
		var bodies = get_children()
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
					
				var new_poly = Geometry.offset_polygon_2d(poly, local_offset, Geometry.JOIN_SQUARE)[0]
				outlines.append(new_poly)
		
		var outer_points = PoolVector2Array([-size/2, Vector2(size.x, -size.y)/2, size/2, Vector2(-size.x, size.y)/2])
		outlines.append(outer_points)
		
		var nav_poly: NavigationPolygon = NavigationPolygon.new()
		for outline in outlines:
			nav_poly.add_outline(outline)
		nav_poly.make_polygons_from_outlines() #fails if "convex partition failed"
		get_node(target).navpoly = nav_poly
