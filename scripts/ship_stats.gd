extends Node

## Signals

signal on_shield_amount_changed(new_amount: float)
signal on_oxygen_amount_changed(new_amount: float)
signal on_energy_amount_changed(new_amount: float)
signal on_alignment_amount_changed(new_amount: float)

signal on_game_timer_amount_changed(new_amount: float)

signal on_win()
signal on_lose()

const _MAX_STAT_AMOUNT: float = 100.0

const _SHIELD_AMOUNT_INITIAL: float = 100.0
const _OXYGEN_AMOUNT_INITIAL: float = 100.0
const _ENERGY_AMOUNT_INITIAL: float = 100.0
const _ALIGNMENT_AMOUNT_INITIAL: float = 100.0

const _GAME_TIMER_AMOUNT_INITIAL: float = 5.0 * 60.0 ## 5 minutes

## Public variables

## The timer itself
var game_timer: float:
	set(value):
		game_timer = maxf(value, 0.0)
		on_game_timer_amount_changed.emit(game_timer)

		# if is_equal_approx(game_timer, 0.0):
		# 	game_ended = false
		# 	on_win.emit()

func trigger_the_win() -> void:
	on_win.emit()

## Should the game timer be counting down?
## Use this to pause / play
var pause_timer: bool = true

## Also stops the timer but tells you when the games over
var game_ended: bool = true


## Modify these and not the initial amount
var shield_amount: float = 0.0:
	set(value):
		shield_amount = clampf(value, 0, _MAX_STAT_AMOUNT)
		on_shield_amount_changed.emit(shield_amount)

		## lose condition
		if is_equal_approx(shield_amount, 0.0):
			game_ended = true
			on_lose.emit()

var oxygen_amount: float = 0.0:
	set(value):
		oxygen_amount = clampf(value, 0, _MAX_STAT_AMOUNT)
		on_oxygen_amount_changed.emit(oxygen_amount)

		## lose condition
		if is_equal_approx(oxygen_amount, 0.0):
			game_ended = true
			on_lose.emit()

var energy_amount: float = 0.0:
	set(value):
		energy_amount = clampf(value, 0, _MAX_STAT_AMOUNT)
		on_energy_amount_changed.emit(energy_amount)

		## lose condition
		if is_equal_approx(energy_amount, 0.0):
			game_ended = true
			on_lose.emit()

var alignment_amount: float = 0.0:
	set(value):
		alignment_amount = clampf(value, 0, _MAX_STAT_AMOUNT)
		on_alignment_amount_changed.emit(alignment_amount)

		## lose condition
		if is_equal_approx(alignment_amount, 0.0):
			game_ended = true
			on_lose.emit()


## Public Methods

func start_new_game(new_timer: float = -1.0) -> void:
	_setup_initial_values()

	if new_timer > 0.0:
		game_timer = new_timer

	game_ended = false
	pause_timer = false


## Private Methods

func _ready() -> void:
	_setup_initial_values()


func _setup_initial_values() -> void:
	shield_amount = _SHIELD_AMOUNT_INITIAL
	oxygen_amount = _OXYGEN_AMOUNT_INITIAL
	energy_amount = _ENERGY_AMOUNT_INITIAL
	alignment_amount = _ALIGNMENT_AMOUNT_INITIAL
	game_timer = _GAME_TIMER_AMOUNT_INITIAL


func _process(delta: float) -> void:
	if not pause_timer and not game_ended:
		game_timer -= delta
