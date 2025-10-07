extends Area2D
signal hit

#whenever the player enters the ground, emit the hit signal
func _on_body_entered(body: Node2D) -> void:
	hit.emit()
