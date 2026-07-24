extends Label

var action_timer: float = 0.0

func _process(delta: float) -> void:
	action_timer += delta
	position.y = sin(action_timer) * 30 + 120
