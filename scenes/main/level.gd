tool
extends Node2D

export var width: float = 2048
export var height: float = 1200
export var offset: float = 45
export var circle_res: int = 10
export var target: NodePath
export var bake: bool = false setget run_bake

func run_bake(_b):
	if Engine.is_editor_hint():
		bake_()

func bake_() -> void:
	if target:
		var local_offset = offset
		
		var nav_poly: NavigationPolygon = NavigationPolygon.new()
		nav_poly.add_outline(PoolVector2Array([Vector2(-width/2, -height/2), Vector2(width/2, -height/2), Vector2(width/2, height/2), Vector2(-width/2, height/2)]))
		
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
						local_offset = (offset + rad)/cos(PI / circle_res) - rad #https://en.wikipedia.org/wiki/Apothem
						print(local_offset)
						poly = PoolVector2Array()
						for i in range(0, circle_res):
							poly.push_back((Vector2.UP*rad).rotated(i * (2 * PI)/circle_res))
					else:
						continue
				else:
					continue
					
				for i in range(0, poly.size()):
					var temp = poly[i].rotated(collider.rotation) + collider.position
					poly.set(i, temp.rotated(body.rotation) + body.position)
					
				var new_poly = Geometry.offset_polygon_2d(poly, local_offset, Geometry.JOIN_SQUARE)[0]
				nav_poly.add_outline(new_poly)
				
		nav_poly.make_polygons_from_outlines()
		get_node(target).navpoly = nav_poly
