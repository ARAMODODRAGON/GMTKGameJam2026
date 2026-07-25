extends Node

signal on_small_hit(strength: float)
signal on_big_hit(strength: float)

## Public Variables

@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var rock_interval_min: float = 3.0
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var rock_interval_max: float = 15.0

@export var frequency_redux_at_low_shield: float = 0.3
@export var low_shield_threshold: float = 20.0
@export var low_shield_hit_strength_multiplier: float = 2.0

@export_range(0.0, 100.0, 0.1, "suffix:%")
var big_asteroid_chance: float = 10.0

@export_group("Stat reductions")

@export_subgroup("Oxygen", "oxygen_")
@export var oxygen_reduction_enabled: bool = true
@export var oxygen_reduction_min: float = 1.0
@export var oxygen_reduction_max: float = 10.0

@export_subgroup("Shield", "shield_")
@export var shield_reduction_enabled: bool = true
@export var shield_reduction_min: float = 1.0
@export var shield_reduction_max: float = 10.0

@export_subgroup("Energy", "energy_")
@export var energy_reduction_enabled: bool = true
@export var energy_reduction_min: float = 1.0
@export var energy_reduction_max: float = 10.0

@export_subgroup("Alignment", "alignment_")
@export var alignment_reduction_enabled: bool = true
@export var alignment_reduction_min: float = 1.0
@export var alignment_reduction_max: float = 10.0


@export_group("Asteroid requirements")
@export var min_required_oxygen: float = 80.0
@export var min_required_shield: float = 80.0
@export var min_required_energy: float = 80.0
@export var min_required_alignment: float = 80.0

@export_group("Visuals")

@export var small_hit_shake_min: float = 3.0
@export var small_hit_shake_max: float = 20.0

@export var big_hit_shake_min: float = 10.0
@export var big_hit_shake_max: float = 10.0


## Private Variables

var _timer_to_next_hit: float = 10000.0


## Virtual Methods

func _ready() -> void:
	_set_next_interval.call_deferred()


func _process(delta: float) -> void:
	_timer_to_next_hit -= delta
	if _timer_to_next_hit <= 0.0:
		_set_next_interval()
		_handle_hit()


func _unhandled_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_0 and keyevent.pressed:
		_timer_to_next_hit = 0.0


## Private Methods

func _should_be_asteroid() -> bool:
	if min_required_oxygen > ShipStats.oxygen_amount:
		return false

	if min_required_energy > ShipStats.energy_amount:
		return false

	if min_required_shield > ShipStats.shield_amount:
		return false

	if min_required_alignment > ShipStats.alignment_amount:
		return false

	var chance := randf_range(0.0, 100.0)
	return chance <= big_asteroid_chance


func _set_next_interval() -> void:
	#var scale := (ShipStats.shield_amount / ShipStats._SHIELD_AMOUNT_INITIAL)
	#_timer_to_next_hit += randf_range(0.0, rock_interval_diff) * scale
	_timer_to_next_hit = randf_range(rock_interval_min, rock_interval_max)

	if ShipStats.shield_amount < low_shield_threshold:
		_timer_to_next_hit *= frequency_redux_at_low_shield


func _handle_hit() -> void:
	if not _should_be_asteroid():
		#print("small hit")
		_handle_small_rock()
	else:
		#print("big hit")
		_handle_asteroid()


func _handle_small_rock() -> void:
	## handle small rock
	var shake_amount := randf_range(small_hit_shake_min, small_hit_shake_max) * low_shield_hit_strength_multiplier
	EffectsManager.shake_screen(shake_amount)
	on_small_hit.emit(shake_amount)


func _handle_asteroid() -> void:
	## shake screen
	var shake_amount := randf_range(big_hit_shake_min, big_hit_shake_max) * low_shield_hit_strength_multiplier
	EffectsManager.shake_screen(shake_amount)
	on_big_hit.emit(shake_amount)

	## handle stat changes

	if oxygen_reduction_enabled:
		ShipStats.oxygen_amount -= randf_range(oxygen_reduction_min, oxygen_reduction_max)

	if shield_reduction_enabled:
		ShipStats.shield_amount -= randf_range(shield_reduction_min, shield_reduction_max)

	if energy_reduction_enabled:
		ShipStats.energy_amount -= randf_range(energy_reduction_min, energy_reduction_max)

	if alignment_reduction_enabled:
		ShipStats.alignment_amount -= randf_range(alignment_reduction_min, alignment_reduction_max)
