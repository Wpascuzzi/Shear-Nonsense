extends Area2D

signal score_updated(score)

const SCORE_FACTOR = 100

# the wool object to calculate score on
var wool : SheepWool
var pos_score : int = 0
var neg_score : int = 0
var max_score : int = 0
var total_score : int = 0

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score_updated.connect(global_info.on_score_updated)
	global_info.game_started.connect(on_game_start)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if max_score != 0:
		calculate_scores()
		total_score = (pos_score + neg_score)/float(max_score) * SCORE_FACTOR
		score_updated.emit(total_score)

func on_game_start():
	calculate_scores()
	max_score = pos_score
	
func calculate_scores():
	pos_score = 0
	neg_score = 0
	var clump_map : Array = wool.clump_map
	for col_idx in clump_map.size():
		var col = clump_map[col_idx]
		for clump in col:
			if not is_instance_valid(clump) or not clump is WoolClump:
				continue
			if Geometry2D.is_point_in_polygon(clump.position, collision_polygon_2d.polygon):
				pos_score += 1
				clump.modulate = Color(Color.REBECCA_PURPLE)
				clump.z_index = 1
			else:
				neg_score -= 1
				clump.modulate = Color(Color.RED)
				#print("modulated red")
				# there's definitely a better calculation here that involves the ratio of clumps inside and out and maybe original clumps
				# it's also 4:41 so i dont wanna do right now
	
