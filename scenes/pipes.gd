extends Node2D
signal hit
signal scored

var _initial_position:Vector2

func _ready() -> void:
	_initial_position = position

func _on_upper_pipe_body_entered(body: Node2D) -> void:
	hit.emit()


func _on_score_area_body_entered(body: Node2D) -> void:
	scored.emit()

func reset():
	position = _initial_position
