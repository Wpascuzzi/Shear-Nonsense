extends RichTextLabel

var score
@onready var score_value: RichTextLabel = $ScoreValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(_score):
	score = _score
	score_value.text = str(score)
