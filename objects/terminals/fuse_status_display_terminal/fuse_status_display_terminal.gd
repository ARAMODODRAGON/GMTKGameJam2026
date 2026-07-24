extends Node3D

@export var fuses: Array[InteractableSwitch]

@export_group("Minigame")
@export_range(0.0, 100.0, 0.001, "suffix:%")
var randomizer_fuse_state_chance: float = 40.0
@export var success_energy_amount: float = 10.0

@export_group("Stats")
@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var energy_usage_rate: float = 1.0

@export_group("References")
@export var fuse_items: Array[FuseItem] = []
@export var button_clip: Control


## Private Variables

@onready var _battery_clip_size: float = button_clip.custom_minimum_size.y
var _on_count: int = 0


## Virtual Methods

func _ready() -> void:
	assert(fuses.size() == 6, "There must be 6 fuses")

	await get_tree().process_frame

	for i in range(fuses.size()):
		if not fuses[i]:
			print("Missing fuse in slot ", i)
			continue
		fuses[i].switched.connect(_update_display.bind(i))
		if fuses[i].state:
			_on_count += 1

		#region debug
		if fuses[i].get_child_count() < 3:
			continue
		var label := fuses[i].get_child(2) as Label3D
		if label:
			label.text = str(i)
			#print(i)
		#endregion

	print(_on_count)
	_randomize_values.call_deferred.call_deferred()


func _process(delta: float) -> void:

	## Reduce energy
	ShipStats.energy_amount -= energy_usage_rate * delta
	#print(ShipStats.energy_amount)

	## Update the energy display
	button_clip.custom_minimum_size.y = remap(ShipStats.energy_amount, 0.0, ShipStats._ENERGY_AMOUNT_INITIAL, 0.0, _battery_clip_size)


## Private Methods

func _update_display(index: int) -> void:
	if index >= fuse_items.size():
		return

	var new_value := fuses[index].state

	fuse_items[index].state = new_value
	if new_value:
		_on_count += 1
	else:
		_on_count -= 1

	#print("real set ", new_value)
	#print(_on_count)

	if _on_count == 6:
		print("success!")
		ShipStats.energy_amount += success_energy_amount
		_randomize_values.call_deferred()


func _randomize_values() -> void:
	#print("randomizing")
	_on_count = 0
	for i in range(fuses.size()):
		var new_val := randf_range(0.0, 100.0) < randomizer_fuse_state_chance
		if new_val != fuses[i].state:
			_on_count += 1
			#print("set ", new_val)
		fuses[i].state = new_val
		fuse_items[i].state = new_val

	print(_on_count)
