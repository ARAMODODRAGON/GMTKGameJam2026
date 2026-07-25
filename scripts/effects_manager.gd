extends Node

signal _camera_shake_screen(amount: float)

func shake_screen(amount: float) -> void:
	_camera_shake_screen.emit(amount)
