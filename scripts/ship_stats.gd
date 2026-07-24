extends Node

## Public variables
var max_stat_amount: float = 100.0

const _SHIELD_AMOUNT_INITIAL: float = 100.0
const _OXYGEN_AMOUNT_INITIAL: float = 50.0
const _ENERGY_AMOUNT_INITIAL: float = 100.0
const _ALIGNMENT_AMOUNT_INITIAL: float = 100.0
## Modify these and not the initial amount
var shield_amount: float = 0.0:
	set(value):
		shield_amount = value
		shield_amount = clampf(shield_amount, 0, max_stat_amount)
		on_shield_amount_changed.emit(shield_amount)

var oxygen_amount: float = 0.0:
	set(value):
		oxygen_amount = value
		oxygen_amount = clampf(oxygen_amount, 0, max_stat_amount)
		on_oxygen_amount_changed.emit(oxygen_amount)

var energy_amount: float = 0.0:
	set(value):
		energy_amount = value
		energy_amount = clampf(energy_amount, 0, max_stat_amount)
		on_energy_amount_changed.emit(energy_amount)

var alignment_amount: float = 0.0:
	set(value):
		alignment_amount = value
		alignment_amount = clampf(alignment_amount, 0, max_stat_amount)
		on_alignment_amount_changed.emit(alignment_amount)

## Signals
signal on_shield_amount_changed(new_amount: float)
signal on_oxygen_amount_changed(new_amount: float)
signal on_energy_amount_changed(new_amount: float)
signal on_alignment_amount_changed(new_amount: float)

func _ready() -> void:
	_setup_initial_values()

func _setup_initial_values() -> void:
	shield_amount = _SHIELD_AMOUNT_INITIAL
	oxygen_amount = _OXYGEN_AMOUNT_INITIAL
	energy_amount = _ENERGY_AMOUNT_INITIAL
	alignment_amount = _ALIGNMENT_AMOUNT_INITIAL