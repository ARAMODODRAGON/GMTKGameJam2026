@abstract
class_name BaseInteractable
extends Area3D


@abstract
func _pressed() -> void

@abstract
func _released() -> void


func _init() -> void:
	collision_layer = 0
	collision_mask = 0

	set_collision_layer_value(3, true)
