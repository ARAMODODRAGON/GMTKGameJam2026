extends Node3D

@export var fuses: Array[InteractableSwitch]
@export var success_button: InteractableButton

@export var low_blip: AudioStreamPlayer3D
@export var normal_blip: AudioStreamPlayer3D
@export var success: AudioStreamPlayer3D

@export_group("Minigame")
@export_range(0.0, 100.0, 0.001, "suffix:%")
var randomizer_fuse_state_chance: float = 40.0
@export var success_energy_amount: float = 10.0
@export var time_to_succeed: float = 5.0

@export_group("Stats")
@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var energy_usage_rate: float = 1.0

@export_group("References")
@export var fuse_items: Array[FuseItem] = []
@export var fuse_targets: Array[FuseItem] = []
@export var success_indicators: Array[ColorRect] = []
#@export var button_clip: Control


## Private Variables

#@onready var _battery_clip_size: float = button_clip.custom_minimum_size.y
var _on_count: int = 0
var _button_held: bool = false
var _success_timer: float = 0.0
var _block_process: bool = false


## Virtual Methods

func _ready() -> void:
	assert(fuses.size() == 6, "There must be 6 fuses")

	for i in fuses.size():
		if not fuses[i]:
			print("Missing fuse in slot ", i)
			continue

		## connect
		fuses[i].state_changed.connect(_set_fuse_display.bind(fuses[i]))

		print("connected", fuses[i].name, " to index ", i)

	success_button.pressed.connect(_button_state_changed.bind(true))
	success_button.released.connect(_button_state_changed.bind(false))

	#print(_on_count)
	_randomize_values()


func _process(delta: float) -> void:
	## Reduce energy
	ShipStats.energy_amount -= energy_usage_rate * delta
	#print(ShipStats.energy_amount)

	if _block_process:
		return

	if _button_held and _on_count == 6:
		_success_timer += delta
		#print(_success_timer)
	elif _success_timer > 0.0:
		_success_timer -= delta

	_update_success_display()

	if _success_timer > time_to_succeed:
		_success_timer -= time_to_succeed

		success.play()

		#print("Success")
		ShipStats.energy_amount	+= success_energy_amount

		_block_process = true

		var tween := create_tween()

		for i in 3:
			tween.set_parallel(false)
			tween.tween_interval(0.1)

			for box in success_indicators:
				tween.tween_property(box, "color:a", 0.0, 0.0)
				tween.set_parallel(true)

			tween.set_parallel(false)
			tween.tween_interval(0.1)

			for box in success_indicators:
				tween.tween_property(box, "color:a", 1.0, 0.0)
				tween.set_parallel(true)

		await tween.finished

		_randomize_values()
		_block_process = false



## Private Methods

func _update_success_display() -> void:
	var value := remap(_success_timer, 0.0, time_to_succeed, 0.0, 6.0)
	#print(_success_timer)

	for i in range(success_indicators.size() - 1, -1, -1):
		var new_value := 1.0 if float(i + 1) <= value else 0.0
		if not is_equal_approx(success_indicators[i].color.a, new_value):
			normal_blip.play()
		success_indicators[i].color.a = new_value

func _button_state_changed(state: bool) -> void:
	_button_held = state
	#print(state)

func _count_matching() -> void:
	_on_count = 0
	for i in fuses.size():
		if fuse_items[i].state == fuse_targets[i].state:
			_on_count += 1

func _set_fuse_display(value: bool, fuse: InteractableSwitch) -> void:
	var index := fuses.find(fuse)
	#print("name ", fuse.name, ", set ", index, " to ", value)
	fuse_items[index].state = value
	_count_matching()

	if fuse_items[index].state == fuse_targets[index].state:
		normal_blip.play()
	else:
		low_blip.play()


func _randomize_values() -> void:
	for i in fuses.size():
		var new_value := randf_range(0.0, 100.0) < randomizer_fuse_state_chance
		fuse_targets[i].state = new_value

	_count_matching()
