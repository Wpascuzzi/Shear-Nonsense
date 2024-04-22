extends Control

@onready var score_text: RichTextLabel = $Score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_info.score_updated.connect(on_score_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_score_updated(score : int):
	score_text.update_score(score)
