class_name OxygenTask
extends Control

## Signals
signal on_oxygen_terminal_success()
signal on_oxygen_terminal_completion()
signal on_oxygen_terminal_failure()


## Public variables
@export var button: InteractableButton
@export var low_blip: AudioStreamPlayer3D
@export var normal_blip: AudioStreamPlayer3D
@export var success_sound: AudioStreamPlayer3D
@export var fail_sound: AudioStreamPlayer3D

@export var red_bar: Control
@export var green_zone: Control
@export var _success_boxes: Array[ColorRect] = []
@export var arrows: Array[TextureRect] = []

@export var move_speed: float
@export var timer_initial: float
@export var stat_success_amount: float = 0.0
@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var stat_usage_rate: float = 1.0
@export var _green_lower_limit: float
@export var _red_lower_limit: float

@export var green: Color
@export var red: Color

## Private variables
var _is_moving_down: bool = true
var _can_move: bool = true
var _is_colliding: bool = false
var _successes: int = 0
var _timer: float
var _should_be_moving: bool = true


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
	if not _should_be_moving:
		return

	if not red_bar:
		print("Red Bar was found to be null")
		return

	if not _can_move:
		return

	if red_bar.position.y <= 0.0:
		_is_moving_down = true
		low_blip.play()
	elif red_bar.position.y >= _red_lower_limit:
		_is_moving_down = false
		low_blip.play()

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
		_choose_new_green_location()
		_success_boxes[_successes].color.a = 1.0
		_successes += 1
		on_oxygen_terminal_success.emit()

		if _successes < 3:
			normal_blip.play()
			return

		success_sound.play()

		ShipStats.oxygen_amount += stat_success_amount
		print(ShipStats.oxygen_amount)
		_successes = 0
		for b in _success_boxes:
			b.color.a = 0.0
		on_oxygen_terminal_completion.emit()
		_should_be_moving = false

		for box in _success_boxes:
			var tween := box.create_tween()

			for i in 3:
				tween.tween_interval(0.1)
				tween.tween_property(box, "color:a", 0.0, 0.0)
				tween.tween_interval(0.1)
				tween.tween_property(box, "color:a", 1.0, 0.0)

			tween.tween_interval(0.1)
			tween.tween_property(box, "color:a", 0.0, 0.0)
			tween.tween_callback(
				func() -> void:
					_should_be_moving = true
			)

	else:
		fail_sound.play()

		_choose_new_green_location()
		_successes = 0
		on_oxygen_terminal_failure.emit()

		for box in _success_boxes:
			box.color = red

			var tween := box.create_tween()

			for i in 3:
				tween.tween_interval(0.1)
				tween.tween_property(box, "color:a", 0.0, 0.0)
				tween.tween_interval(0.1)
				tween.tween_property(box, "color:a", 1.0, 0.0)

			tween.tween_interval(0.1)
			tween.tween_property(box, "color:a", 0.0, 0.0)
			tween.tween_callback(
				func() -> void:
					box.color = green
					box.color.a = 0.0
					_should_be_moving = true
			)


func _choose_new_green_location() -> void:

	if not green_zone:
		print("Green Zone was found to be null")
		return

	##green_zone.position.y = randf_range(_lower_limits, _upper_limits)

	for i in 10:
		var rando: float = randf_range(0.0, _green_lower_limit)

		if abs(rando - green_zone.position.y) > 40:
			green_zone.position.y = rando
			break

	for arrow in arrows:
		arrow.position.y = green_zone.position.y + (green_zone.size.y * 0.5) - (arrow.size.y * 0.5)

## Public Functions
