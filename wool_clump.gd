class_name WoolClump

extends Area2D

signal clump_removed(coordinates)

# a list of neighbor clump objects. 
# Think about if this should instead be a list of coordinates
var neighbors = [] 

var coordinates : Vector2
var anchored : bool
var island_id
var highlight = false

func _ready():
	update_neighbours_added()
	
func _process(delta):
	return
	highlight = false
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area is NeighborChecker:
			highlight = true
	return
	if highlight == false:
		_color_neighbors(Color(1, 1, 1))
	else:
		_color_neighbors(Color(.9, .8, .8))

func _color_neighbors(color):
	for neighbor in neighbors:
		neighbor.modulate = color

func _on_area_entered(area):
	if area is Shaver:
		remove_clump()
		
	# DEBUG STUFF
#	elif area is NeighborChecker:
#		for neighbor in neighbors:
#			print(neighbor.coordinates)
#		_color_neighbors(Color(.9, .8, .8))

func remove_clump():
	update_neighbours_removed()
	clump_removed.emit(coordinates)
	queue_free()

func update_neighbours_added():
	for clump in neighbors:
		clump.neighbors.append(self)

# DEPRECATED vvv

func update_neighbours_removed():
	for clump in neighbors:
		clump.neighbors.erase(self)
		#clump.try_remove_floating()

func try_remove_floating():
	var clump 
	var queue = []
	var visited = {}
	queue.push_front(self)
	while(!queue.is_empty()):
		clump = queue.pop_front()
		if clump.anchored:
			break
		for neighbor in neighbors:
			if !visited.has(neighbor):
				queue.push_front(neighbor)
		if clump.anchored:
			break
		visited[clump] = true

# DEPRECATED ^^^

func set_unanchored():
	anchored = false
	
func set_anchored():
	anchored = true


# finds neighbor coordinates of this hex
func find_neighbors():
	var isEven = coordinates.y as int % 2 == 0
	var neighborArr = []
	if isEven:
		neighborArr.append(coordinates + Vector2(-1, -1))
		neighborArr.append(coordinates + Vector2(0, -1))
		neighborArr.append(coordinates + Vector2(1, 0))
		neighborArr.append(coordinates + Vector2(0, 1))
		neighborArr.append(coordinates + Vector2(-1, 1))
		neighborArr.append(coordinates + Vector2(-1, 0))
	else:
		neighborArr.append(coordinates + Vector2(0, -1))
		neighborArr.append(coordinates + Vector2(1, -1))
		neighborArr.append(coordinates + Vector2(1, 0))
		neighborArr.append(coordinates + Vector2(1, 1))
		neighborArr.append(coordinates + Vector2(0, 1))
		neighborArr.append(coordinates + Vector2(-1, 0))
	return neighborArr
