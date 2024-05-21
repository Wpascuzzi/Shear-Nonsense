extends Node2D


var rotation_speed = 50 # measured in degrees per second
# eventually replace these with an object that stores wool pattern data
var wool_width = 60
var wool_height = 60

@onready var sheep_head = $SheepHead
@onready var sheep_wool = $SheepWool
#@onready var wool_shape_goal: Area2D = $WoolShapeGoal
@onready var wool_shape_goal: Area2D = $SheepWool/WoolShapeGoal

# Called when the node enters the scene tree for the first time.
func _ready():
	sheep_wool.create_hex_map(wool_width, wool_height)
	sheep_wool.generate_wool()
	
	var top_left = Vector2(0,0)
	var bot_right = Vector2(wool_width - 1, wool_height - 1)  * sheep_wool.CLUMP_INTERVAL
	sheep_wool.position = lerp(top_left, bot_right, -0.5)
	
	wool_shape_goal.wool = sheep_wool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_info.is_game_started:
		rotation_degrees += rotation_speed * delta
