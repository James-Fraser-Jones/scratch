tool
extends Node2D

const circle_scene = preload("res://scenes/circle/circle.tscn")

export var nav_path: NodePath

export var particles: int = 10
export var particle_radius: float = 60
export var particle_color: Color = Color.red

export var setup: bool setget run_setup
export var generate: bool setget run_generate
export var delete: bool setget run_delete
export var test: bool setget run_test

var triangles : Array
var cum_areas : Array

func run_setup(_b):
	if Engine.is_editor_hint():
		get_triangles_areas()

func run_generate(_b):
	if Engine.is_editor_hint():
		remove_all_children()
		spawn_particles()
		
func run_delete(_b):
	if Engine.is_editor_hint():
		remove_all_children()
		
func run_test(_b):
	if Engine.is_editor_hint():
		pass
		#print(triangle_area(PoolVector2Array([Vector2.ZERO, Vector2.UP, Vector2.RIGHT])))

##########################################################

func spawn_particles():
	for i in particles:
		var point = get_random_nav_point()
		spawn_particle(point)

func spawn_particle(point: Vector2):
	var circle = circle_scene.instance()
	circle.radius = particle_radius
	circle.color = particle_color
	circle.position = point
	add_child(circle)
	circle.owner = get_tree().get_edited_scene_root()

##########################################################

func get_random_nav_point() -> Vector2:
	var index = rand_area_proportional_triangle(cum_areas)
	return get_uniform_random_triangle_point(triangles[index])
	
func get_triangles_areas():
	triangles = get_triangles()
	cum_areas = get_cumulative_areas(triangles)

##########################################################

#https://www.reddit.com/r/godot/comments/mqp29g/how_do_i_get_a_random_position_inside_a_collision/
#https://math.stackexchange.com/questions/18686/uniform-random-point-in-triangle-in-3d

func get_uniform_random_triangle_point(triangle: PoolVector2Array) -> Vector2:
	var a = triangle[0]
	var b = triangle[1]
	var c = triangle[2]
	var r1 = rand_range(0, 1)
	var r2 = rand_range(0, 1)
	var p = (1 - sqrt(r1))*a + (sqrt(r1)*(1 - r2))*b + (r2*sqrt(r1))*c
	return p

func rand_area_proportional_triangle(cum_areas: Array) -> int:
	var max_area = cum_areas[cum_areas.size()-1]
	var rand_area = rand_range(0, max_area)
	return cum_areas.bsearch(rand_area)

##########################################################

func get_cumulative_areas(triangles: Array) -> Array:
	var cum_areas = []
	var cum_area = 0
	for triangle in triangles:
		var area = triangle_area(triangle)
		cum_area += area
		cum_areas.append(cum_area)
	return cum_areas

func triangle_area(t: PoolVector2Array) -> float:
	return abs((t[0]-t[1]).cross(t[2]-t[1])/2)

func get_triangles() -> Array:
	var triangles = []
	var nav_poly: NavigationPolygon = get_node(nav_path).get_child(0).navpoly
	var vertices = nav_poly.get_vertices()
	for i in nav_poly.get_polygon_count():
		var poly_indices = nav_poly.get_polygon(i)
		var points = PoolVector2Array()
		for index in poly_indices:
			points.append(vertices[index])
		var tri_indices = Geometry.triangulate_polygon(points)
		for j in tri_indices.size()/3:
			var triangle = PoolVector2Array([points[tri_indices[j*3]], points[tri_indices[j*3+1]], points[tri_indices[j*3+2]]])
			triangles.append(triangle)
	return triangles

##########################################################

func generate_triangulated_polygons():
	var nav: Navigation2D = get_node(nav_path)
	var nav_poly: NavigationPolygon = nav.get_child(0).navpoly
	var vertices = nav_poly.get_vertices()
	for i in nav_poly.get_polygon_count():
		var poly_indices = nav_poly.get_polygon(i)
		var points = PoolVector2Array()
		for index in poly_indices:
			points.append(vertices[index])
		var tri_indices = Geometry.triangulate_polygon(points)
		for j in tri_indices.size()/3:
			var tri_points = PoolVector2Array([points[tri_indices[j*3]], points[tri_indices[j*3+1]], points[tri_indices[j*3+2]]])
			var poly = Polygon2D.new()
			poly.polygon = tri_points
			poly.modulate = Color.from_hsv(rand_range(0, 1), 1, 0.5)
			add_child(poly)
			poly.owner = get_tree().get_edited_scene_root() #otherwise won't show up in scene tree

func generate_polygons():
	var nav: Navigation2D = get_node(nav_path)
	var nav_poly: NavigationPolygon = nav.get_child(0).navpoly
	var vertices = nav_poly.get_vertices()
	for i in nav_poly.get_polygon_count():
		var indices = nav_poly.get_polygon(i)
		var points = []
		for index in indices:
			points.append(vertices[index])
		var poly = Polygon2D.new()
		poly.polygon = PoolVector2Array(points)
		poly.modulate = Color.from_hsv(rand_range(0, 1), 1, 0.5)
		add_child(poly)
		poly.owner = get_tree().get_edited_scene_root() #otherwise won't show up in scene tree

##########################################################

func remove_all_children():
	for child in get_children():
		child.queue_free()
