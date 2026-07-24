class_name InteractableSwitch
extends BaseInteractable

signal switched()
signal state_changed(new_value: bool)

## The current switch state
var state: bool = false:
	set(value):
		if state != value:
			state = value
			state_changed.emit(value)


func _pressed() -> void:
	state = not state
	switched.emit()
	print("Pressed")

func _released() -> void:
	print("Released")
	pass
