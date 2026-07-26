class_name AlignmentTask
extends Node2D


## Public variables

@export var pos_x: InteractableButton
@export var neg_x: InteractableButton
@export var pos_y: InteractableButton
@export var neg_y: InteractableButton

@export var success_player: AudioStreamPlayer3D
@export var blip_player: AudioStreamPlayer3D
@export var hold_click: AudioStreamPlayer3D

@export var player_crosshair: CharacterBody2D
@export var player_sprite: Sprite2D
@export var target_crosshair: Area2D

@export var move_speed: float

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var stat_usage_rate: float = 1.0

@export var stat_success_amount: float = 0.0

## Private variables
@export var _upper_bounds: float
@export var _lower_bounds: float
@export var _right_bounds: float
@export var _left_bounds: float

@export var green: Color

var movement_vector: Vector2 = Vector2.ZERO

var _can_move: bool = true
var _flashing_timer: float = 0.0

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

	if movement_vector.length() > 0.1 and not hold_click.playing:
		print("play")
		hold_click.play()
	elif movement_vector.length() <= 0.1 and hold_click.playing:
		print("stop")
		hold_click.stop()


func _physics_process(delta: float) -> void:
	_move_player_crosshair(delta, movement_vector)

	if not _can_move:
		return

	_flashing_timer -= delta
	if _flashing_timer <= 0.0:
		_flashing_timer = 0.5
		target_crosshair.visible = not target_crosshair.visible
		if target_crosshair.visible:
			blip_player.play()


func _move_player_crosshair(delta: float, movement: Vector2) -> void:
	if not _can_move:
		return
	var final_movement: Vector2 = movement * move_speed * delta
	player_crosshair.move_and_collide(final_movement)


func _select_new_target_location() -> void:
	for i in 10:
		var result: Vector2 = Vector2(randf_range(_left_bounds, _right_bounds), randf_range(_upper_bounds, _lower_bounds))
		if result.distance_to(player_crosshair.position) >= 150:
			target_crosshair.position = result
			break


func _on_area_2d_area_entered(area: Area2D) -> void:
	success_player.play()

	on_nav_terminal_completion.emit()
	ShipStats.alignment_amount += stat_success_amount

	_can_move = false
	target_crosshair.visible = false

	player_sprite.modulate = green
	player_sprite.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_interval(0.1)

	for i in 3:
		tween.tween_property(player_sprite, "modulate:a", 1.0, 0.0)
		tween.tween_interval(0.1)
		tween.tween_property(player_sprite, "modulate:a", 0.0, 0.0)
		tween.tween_interval(0.1)

	await tween.finished

	player_sprite.modulate = Color.WHITE
	player_sprite.modulate.a = 1.0

	_select_new_target_location()
	_can_move = true
	target_crosshair.visible = true


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
