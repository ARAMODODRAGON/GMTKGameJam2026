class_name InteractableButton
extends BaseInteractable

var is_held: bool = false

signal pressed()
signal released()

func _pressed() -> void:
	pressed.emit()
	is_held = true
	#print("Pressed")

func _released() -> void:
	released.emit()
	is_held = false
	#print("Released")
