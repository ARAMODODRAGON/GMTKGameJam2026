extends Node3D

@export var fuses: Array[InteractableButton]

@export_group("Stats")
@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var energy_usage_rate: float = 1.0

@export_group("References")
@export var fuse_items: Array[FuseItem] = []
@export var button_clip: Control


@onready var _battery_clip_size: float = button_clip.custom_minimum_size.y

func _update_display(index: int) -> void:
	if index >= fuse_items.size():
		return

	fuse_items[index].state = not fuse_items[index].state

func _ready() -> void:
	for i in range(fuses.size()):
		fuses[i].pressed.connect(_update_display.bind(i), true)


func _process(delta: float) -> void:

	## Reduce energy
	ShipStats.energy_amount -= energy_usage_rate * delta
	#print(ShipStats.energy_amount)

	## Update the energy display
	button_clip.custom_minimum_size.y = remap(ShipStats.energy_amount, 0.0, ShipStats._ENERGY_AMOUNT_INITIAL, 0.0, _battery_clip_size)
