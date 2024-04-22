class_name SheepWool

extends Node2D

const CLUMP_INTERVAL = 5 # distance between clumps in a row
const pl_wool_clump = preload("res://wool_clump.tscn")

var clump_map = []
var center : WoolClump
var width
var height

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	check_anchored_clumps()

# Generates the sheep's wool coat
# may add parameters to take data for different shape templates
# for now, just generate a circular coat
func generate_wool():
	populate_clump_map()
	center = clump_map[width/2][height/2]
	
# we will create a grid of clumps using hex-based tiling
# width: the number of horizontal coordinates on the map
# height: the number of vertical coordinates on the map
func create_hex_map(_width, _height):
	clump_map.resize(_width)
	for i in len(clump_map):
		clump_map[i] = create_hex_map_column(_height)
	self.width = _width
	self.height = _height

# create a column for the hex map
func create_hex_map_column(_height):
	var column = []
	column.resize(_height)
	# FOR TESTING
	column.fill(true)
	return column

# add wool clumps to the clump hex map
func populate_clump_map():
	for x in len(clump_map):
		var col = clump_map[x]
		for y in len(col):
			if col[y] == true:
				col[y] = add_wool_clump(x, y)
				
func add_wool_clump(x, y):
	var clump = pl_wool_clump.instantiate()
	clump.position = Vector2(x + (abs(y % 2 - 1) * 0.5), y) * CLUMP_INTERVAL
	clump.coordinates = Vector2(x,y)
	for coord in clump.find_neighbors():
		if (coord.x >= len(clump_map) or 
		coord.y >= len(clump_map[0])  or 
		coord.x < 0 or coord.y < 0):
			continue
		var possible_neighbor = clump_map[coord.x][coord.y]
		if possible_neighbor is WoolClump:
			clump.neighbors.append(possible_neighbor)
	
	clump.clump_removed.connect(remove_clump_from_map)
				
	add_child(clump)
	return clump


func remove_clump_from_map(coordinates : Vector2):
	clump_map[coordinates.x][coordinates.y] = null


func check_anchored_clumps():
	for col in clump_map:
		for clump in col:
			if clump is WoolClump:
				clump.set_unanchored()
	flood_fill_anchored_clumps()
	for col in clump_map:
		for clump in col:
			if clump is WoolClump and !clump.anchored:
				clump.remove_clump()

# BFS flood fill starting from the center of the wool 
# to find clumps that are and aren't anchored to the sheep
# TODO: check if we actually need the visited map or can just use the anchored flag
func flood_fill_anchored_clumps():
	var queue = []
	var clump : WoolClump
	if is_instance_valid(center):
		queue.push_front(center)
	while(!queue.is_empty()):
		clump = queue.pop_front()
		for neighbor in clump.neighbors:
			if neighbor and !neighbor.anchored:
				queue.push_front(neighbor)
		clump.set_anchored()
