extends Node

signal _camera_shake_screen(amount: float)
signal _pointer_set_hitting_interactable(state: bool)

func shake_screen(amount: float) -> void:
	_camera_shake_screen.emit(amount)
