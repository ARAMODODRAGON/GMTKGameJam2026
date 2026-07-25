class_name AlignmentTask
extends Node2D


## Public variables
@export var player_crosshair: CharacterBody2D
@export var target_crosshair: Area2D

@export var move_speed: float

@export var pos_x: InteractableButton
@export var neg_x: InteractableButton
@export var pos_y: InteractableButton
@export var neg_y: InteractableButton

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var stat_usage_rate: float = 1.0

@export var stat_success_amount: float = 0.0

## Private variables
@export var _upper_bounds: float
@export var _lower_bounds: float
@export var _right_bounds: float
@export var _left_bounds: float

var movement_vector: Vector2 = Vector2.ZERO

## Signals
signal on_nav_terminal_completion()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not pos_x or not neg_x or not pos_y or not neg_y:
		print("One of the buttons was found to be null")
		return

	_select_new_target_location()

	pos_x.pressed.connect(_positive_x_pressed)
	pos_x.released.connect(_positive_x_released)

	neg_x.pressed.connect(_negative_x_pressed)
	neg_x.released.connect(_negative_x_released)

	pos_y.pressed.connect(_positive_y_pressed)
	pos_y.released.connect(_positive_y_released)

	neg_y.pressed.connect(_negative_y_pressed)
	neg_y.released.connect(_negative_y_released)


func _process(delta: float) -> void:
	ShipStats.alignment_amount -= stat_usage_rate * delta

func _physics_process(delta: float) -> void:
	_move_player_crosshair(delta, movement_vector)

func _move_player_crosshair(delta: float, movement: Vector2) -> void:
	var final_movement: Vector2 = movement * move_speed * delta
	player_crosshair.move_and_collide(final_movement)
	
func _select_new_target_location() -> void:

	for i in 10:
		var result: Vector2 = Vector2(randf_range(_left_bounds, _right_bounds), randf_range(_upper_bounds, _lower_bounds))
		if result.distance_to(player_crosshair.position) >= 150:
			target_crosshair.position = result
			break

func _positive_x_pressed() -> void:
	movement_vector.x = 1.0
	
func _positive_x_released() -> void:
	movement_vector.x = 0.0

func _negative_x_pressed() -> void:
	movement_vector.x = -1.0

func _negative_x_released() -> void:
	movement_vector.x = 0.0

func _positive_y_pressed() -> void:
	movement_vector.y = -1.0

func _positive_y_released() -> void:
	movement_vector.y = 0.0

func _negative_y_pressed() -> void:
	movement_vector.y = 1.0

func _negative_y_released() -> void:
	movement_vector.y = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	on_nav_terminal_completion.emit()
	ShipStats.alignment_amount += stat_success_amount
	_select_new_target_location()
