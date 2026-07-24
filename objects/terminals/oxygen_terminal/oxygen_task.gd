class_name OxygenTask
extends Node2D


## Public variables
@export var red_bar: Area2D
@export var green_zone: Area2D
@export var container: Sprite2D
@export var move_speed: float

@export var button: InteractableButton

var timer: float
@export var timer_initial: float

## Private variables
@export var _upper_limits: float
@export var _lower_limits: float

var _is_moving_down: bool = true
var _can_move: bool = true
var _is_colliding: bool = false
@export var _success_boxes: Array[Sprite2D] = []
var _successes: int = 0

@export var stat_success_amount: float = 0.0


func _ready() -> void:
	_choose_new_green_location()
	
	if not button:
		print("Button was found to be null")
		return
	button.pressed.connect(_stop_red_bar)

func _physics_process(delta: float) -> void:
	move_red_bar(delta)

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		if timer <= 0:
			_can_move = true

func move_red_bar(delta: float) -> void:
	
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
	timer = timer_initial

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
	else:
		print("Fail")
		_choose_new_green_location()
		_successes = 0
		for b in _success_boxes:
			b.visible = false

func _choose_new_green_location() -> void:

	if not green_zone:
		print("Green Zone was found to be null")
		return

	green_zone.position.y = randf_range(_lower_limits, _upper_limits)
