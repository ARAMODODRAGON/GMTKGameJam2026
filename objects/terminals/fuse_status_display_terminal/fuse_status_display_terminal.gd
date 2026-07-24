extends Node3D

@export var fuse_items: Array[FuseItem]
@export var fuses: Array[InteractableButton]

func _update_display(index: int) -> void:
	if index > fuse_items.size():
		return

	fuse_items[index].state = not fuse_items[index].state

func _ready() -> void:
	for i in range(fuses.size()):
		fuses[i].pressed.connect(_update_display.bind(i), true)
