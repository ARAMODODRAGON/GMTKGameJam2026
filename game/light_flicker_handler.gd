extends Node

## Public Variables

@export var light_group: StringName

@export_range(0.0, 100.0, 0.01, "suffix:%")
var min_flicker_amount: float = 50.0
@export_range(0.0, 100.0, 0.01, "suffix:%")
var max_flicker_amount: float = 100.0

@export var flicker_frequency_min: float = 10.0
@export var flicker_frequency_max: float = 30.0

@export var low_energy_threshold: float = 20.0
@export var low_energy_flicker_frequency_multipler: float = 2.0

@export var min_flash_count: int = 1
@export var max_flash_count: int = 7
@export var min_flash_length: float = 0.01
@export var max_flash_length: float = 0.1
@export var light_change_speed: float = 0.01


## Private Variables

var _lights: Array[Light3D] = []
var _flicker_timer: float = 100000.0


## Virtual Methods

func _ready() -> void:
	_lights.assign(get_tree().get_nodes_in_group(light_group))
	_set_timer.call_deferred()


func _process(delta: float) -> void:
	var factor := 1.0 - clampf(ShipStats.energy_amount / low_energy_threshold, 0.0, 1.0)
	_flicker_timer -= delta * lerpf(1.0, low_energy_flicker_frequency_multipler, factor)
	if _flicker_timer <= 0.0:
		_set_timer()
		_apply_flicker()


func _unhandled_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_9 and keyevent.pressed:
		ShipStats.energy_amount -= 1.0


## Private Methods

func _set_timer() -> void:
	_flicker_timer = randf_range(flicker_frequency_min, flicker_frequency_max)
	print("timer ", _flicker_timer)


func _apply_flicker() -> void:
	var flicker_amount := randf_range(min_flicker_amount, max_flicker_amount)

	for light in _lights:
		if randf_range(0.0, 100.0) > flicker_amount:
			continue

		var flicker_count := randi_range(min_flash_count, max_flash_count)
		var tween := light.create_tween()

		for i in flicker_count:
			_add_flicker(light, tween)


func _add_flicker(light: Light3D, tween: Tween) -> void:
	var base_value := light.light_energy
	tween.tween_interval(randf_range(min_flash_length, max_flash_length))
	tween.tween_property(light, "light_energy", 0.0, light_change_speed)
	tween.tween_interval(randf_range(min_flash_length, max_flash_length))
	tween.tween_property(light, "light_energy", base_value, light_change_speed)
