class_name InteractableButton
extends BaseInteractable

signal pressed()
signal released()

func _pressed() -> void:
	pressed.emit()

func _released() -> void:
	released.emit()
