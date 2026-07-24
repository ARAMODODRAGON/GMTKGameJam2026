class_name OxygenTask
extends Node2D


## Public variables
@export var red_bar: Area2D
@export var green_zone: Area2D
@export var move_speed: float

@export var button: InteractableButton

@export var timer_initial: float

@export var stat_success_amount: float = 0.0

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var stat_usage_rate: float = 1.0

## Private variables
@export var _upper_limits: float
@export var _lower_limits: float

var _is_moving_down: bool = true
var _can_move: bool = true
var _is_colliding: bool = false

@export var _success_boxes: Array[Sprite2D] = []
var _successes: int = 0

var _timer: float

## Signals
signal on_oxygen_terminal_success()
signal on_oxygen_terminal_completion()
signal on_oxygen_terminal_failure()

## Private functions
func _ready() -> void:
	_choose_new_green_location()

	if not button:
		print("Button was found to be null")
		return
	button.pressed.connect(_stop_red_bar)

func _physics_process(delta: float) -> void:
	_move_red_bar(delta)

func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
		if _timer <= 0:
			_can_move = true

	ShipStats.oxygen_amount -= stat_usage_rate * delta


func _move_red_bar(delta: float) -> void:

	if not red_bar:
		print("Red Bar was found to be null")
		return

	if not _can_move:
		return

	if red_bar.position.y <= _upper_limits:
		_is_moving_down = true
	elif red_bar.position.y >= _lower_limits:
		_is_moving_down = false

	if _is_moving_down:
		red_bar.position.y += move_speed * delta
	else:
		red_bar.position.y -= move_speed * delta

func _on_red_bar_area_entered(area: Area2D) -> void:
	_is_colliding = true

func _on_red_bar_area_exited(area: Area2D) -> void:
	_is_colliding = false

func _stop_red_bar() -> void:
	if not _can_move:
		return

	_can_move = false
	_timer = timer_initial

	if _is_colliding:
		print("Success")
		_choose_new_green_location()
		_success_boxes[_successes].visible = true
		_successes += 1
		if _successes >= 3:
			ShipStats.oxygen_amount += stat_success_amount
			print(ShipStats.oxygen_amount)
			_successes = 0
			for b in _success_boxes:
				b.visible = false
			on_oxygen_terminal_completion.emit()
			return

		on_oxygen_terminal_success.emit()
	else:
		print("Fail")
		_choose_new_green_location()
		_successes = 0
		on_oxygen_terminal_failure.emit()
		for b in _success_boxes:
			b.visible = false

func _choose_new_green_location() -> void:

	if not green_zone:
		print("Green Zone was found to be null")
		return

	##green_zone.position.y = randf_range(_lower_limits, _upper_limits)

	for i in 10:
		var rando: float = randf_range(_lower_limits, _upper_limits)

		if abs(rando - green_zone.position.y) > 20:
			green_zone.position.y = rando
			break

## Public Functions
