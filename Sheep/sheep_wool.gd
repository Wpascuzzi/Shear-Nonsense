class_name SheepWool

extends Node2D

signal anchored_clumps_checked

const CLUMP_INTERVAL = 5 # distance between clumps in a row
const MAX_CLUMPS_PER_FRAME = 150
const pl_wool_clump = preload("res://Sheep/wool_clump.tscn")

var clump_map = []
var center : WoolClump
var width
var height
var has_checked_anchored = false
var thread_anchored_check : Thread
var semaphor_anchored_check : Semaphore
var mutex_anchored_check : Mutex
var exit_thread := false


@onready var timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	anchored_clumps_checked.connect(check_anchored_clumps.bind(MAX_CLUMPS_PER_FRAME))
	
	mutex_anchored_check = Mutex.new()
	semaphor_anchored_check = Semaphore.new()
	exit_thread = false
	
	thread_anchored_check = Thread.new()
	#thread_anchored_check.start(_anchor_thread_func)

	
	timer.timeout.connect(check_anchored_clumps.bind(MAX_CLUMPS_PER_FRAME))
	timer.start()
	#await check_anchored_clumps(10)
	
	
func _process(delta):
	pass
	#has_checked_anchored = false                                                                               
		
#	if not has_checked_anchored:
#		has_checked_anchored = true
#		check_anchored_clumps()

func _anchor_thread_func():
	while true:
		semaphor_anchored_check.wait()
		
		mutex_anchored_check.lock()
		var should_exit = exit_thread
		mutex_anchored_check.unlock()
		
		if should_exit:
			break
		
		mutex_anchored_check.lock()
		call_deferred("check_anchored_clumps", 50)
		print("checked")
		mutex_anchored_check.unlock()

func _exit_tree():
	mutex_anchored_check.lock()
	exit_thread = true
	mutex_anchored_check.unlock()
	
	semaphor_anchored_check.post()
	
	thread_anchored_check.wait_to_finish()

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



# clumps_per_frame - determines the maximum number of clumps that may be processed in a given physics frame
func check_anchored_clumps(clumps_per_frame := -1):
	var clump_map_snap = clump_map.duplicate(true)
	
	var processed_clumps = 0
	
	#Step 1. set all clumps to be unanchored
	for col in clump_map_snap:
		for clump in col:
			if is_instance_valid(clump) and clump is WoolClump:
				clump.set_unanchored()
				
			processed_clumps += 1
			if clumps_per_frame >= 0 and processed_clumps >= clumps_per_frame:
				await get_tree().physics_frame
				processed_clumps = 0
	
	#Step 2. flood fill to determine which clumps are actually anchored and set them as so
	await flood_fill_anchored_clumps(clumps_per_frame)
	
	
	#step 3. remove all unanchored clumps
	for col in clump_map_snap:
		for clump in col:
			if is_instance_valid(clump) and clump is WoolClump and !clump.anchored:
				clump.remove_clump()
				
			processed_clumps += 1
			if clumps_per_frame >= 0 and processed_clumps >= clumps_per_frame:
				await get_tree().physics_frame
				processed_clumps = 0
	
	anchored_clumps_checked.emit()
	print("fin")



# BFS flood fill starting from the center of the wool 
# to find clumps that are and aren't anchored to the sheep
func flood_fill_anchored_clumps(clumps_per_frame := -1):
	var processed_clumps = 0
	var queue = []
	var clump 
	if is_instance_valid(center):
		queue.push_front(center)
	while(!queue.is_empty()):
		clump = queue.pop_front()
		if not is_instance_valid(clump):
			continue
		for neighbor in clump.neighbors:
			if neighbor and !neighbor.anchored:
				queue.push_front(neighbor)
		clump.set_anchored()
		
		processed_clumps += 1
		if clumps_per_frame >= 0 and processed_clumps >= clumps_per_frame:
			await get_tree().physics_frame
			processed_clumps = 0
