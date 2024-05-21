extends Node

signal game_started
signal score_updated(score)

var score : int = 0
var is_game_started : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		game_started.emit()
		is_game_started = true

func on_score_updated(_score : int):
	score = _score
	score_updated.emit(score)
