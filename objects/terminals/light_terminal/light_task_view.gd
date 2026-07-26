class_name LightTaskView
extends Node2D

## Enums
enum PowerState
{
	OFF,
	NAV,
	OXYGEN,
	SHIELD,
	ENERGY
}


## Public variables
@export var nav_switch: InteractableSwitch
@export var oxygen_switch: InteractableSwitch
@export var shield_switch: InteractableSwitch
@export var energy_switch: InteractableSwitch


@export var nav_door: ShipDoor
@export var energy_door: ShipDoor
@export var oxygen_door: ShipDoor
@export var shield_door: ShipDoor

@export var audioplayer: AudioStreamPlayer3D
@export var success_sound: AudioStream
@export var failure_sound: AudioStream
@export var blip_sound: AudioStream

@export var nav_rect: ColorRect
@export var shield_rect: ColorRect
@export var oxygen_rect: ColorRect
@export var energy_rect: ColorRect

@export var on_colour: Color
@export var selected_colour: Color
@export var off_colour: Color

@export var main_breaker: InteractableButton
@export var auxiliary_breaker: InteractableButton

@export var button_hold_timer: float

@export var nav_lights: Array[Light3D] = []
@export var oxygen_lights: Array[Light3D] = []
@export var shield_lights: Array[Light3D] = []
@export var energy_lights: Array[Light3D] = []

@export var success_indicators: Array[ColorRect] = []

@export var error_text: RichTextLabel

## Private variables

var _timer: float = 0.0
var _is_held: bool = false
var _needs_refresh: bool = false
var _current_selections: Array[PowerState] = []
var _block_process: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_breaker.pressed.connect(_on_button_held)
	main_breaker.released.connect(_on_button_released)

	nav_switch.state_changed.connect(select_nav)
	oxygen_switch.state_changed.connect(select_oxygen)
	energy_switch.state_changed.connect(select_energy)
	shield_switch.state_changed.connect(select_shield)

	nav_switch.state = false
	oxygen_switch.state = false
	energy_switch.state = false
	shield_switch.state = false

	for box in success_indicators:
		box.color.a = 0.0
	show_error_text(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _block_process:
		return

	if _is_held:
		update_success_boxes()
		_timer += delta
		if _timer >= button_hold_timer:
			if _current_selections.size() > 1 or _current_selections.size() <= 0:
				fail_success_boxes()
			else:
				_reroute_power()
				_timer = 0.0
				reset_success_boxes()


func _on_button_held() -> void:
	if _block_process:
		return

	#if not _current_selections.size() > 1 and not _current_selections.size() <= 0:
	if true:
		_is_held = true
		var index: float = remap(_timer, 0.0, button_hold_timer, 0.0, 6.0)

		for i in success_indicators.size() - 1:
			if i + 1 <= index:
				if success_indicators[i].color.a < 1.0:
					audioplayer.stream = blip_sound
					audioplayer.play()
				success_indicators[i].color.a = 1.0
			else:
				success_indicators[i].color.a = 0.0
		print("Main power held")
	else:
		#fail_success_boxes()
		pass

func _on_button_released() -> void:
	_is_held = false
	print("Main power released")
	_timer = 0.0
	if _block_process:
		return
	for box in success_indicators:
		box.color.a = 0.0

func _reroute_power() -> void:
	if _current_selections.size() == 1:
		send_power(_current_selections[0])
	else:
		pass

func send_power(room: PowerState) -> void:
	match room:
		PowerState.NAV:
			set_light_visibility(nav_lights, true)
			set_light_visibility(oxygen_lights, false)
			set_light_visibility(shield_lights, false)
			set_light_visibility(energy_lights, false)
			nav_rect.color = on_colour
			_needs_refresh = true
			set_door_state(nav_door, true)
			set_door_state(energy_door, false)
			set_door_state(oxygen_door, false)
			set_door_state(shield_door, false)
			print("Power send to nav")
		PowerState.OXYGEN:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, true)
			set_light_visibility(shield_lights, false)
			set_light_visibility(energy_lights, false)
			oxygen_rect.color = on_colour
			_needs_refresh = true
			set_door_state(nav_door, false)
			set_door_state(energy_door, false)
			set_door_state(oxygen_door, true)
			set_door_state(shield_door, false)
			print("Power send to oxygen")
		PowerState.ENERGY:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, false)
			set_light_visibility(shield_lights, false)
			set_light_visibility(energy_lights, true)
			energy_rect.color = on_colour
			_needs_refresh = true
			set_door_state(nav_door, false)
			set_door_state(energy_door, true)
			set_door_state(oxygen_door, false)
			set_door_state(shield_door, false)
			print("Power send to energy")
		PowerState.SHIELD:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, false)
			set_light_visibility(shield_lights, true)
			set_light_visibility(energy_lights, false)
			shield_rect.color = on_colour
			_needs_refresh = true
			set_door_state(nav_door, false)
			set_door_state(energy_door, false)
			set_door_state(oxygen_door, false)
			set_door_state(shield_door, true)
			print("Power send to shields")

func select_nav(state: bool) -> void:
	audioplayer.stream = blip_sound
	audioplayer.play()

	if _needs_refresh:
		refresh_light_colour()

	if state:
		_current_selections.push_back(PowerState.NAV)
		nav_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.NAV)
		nav_rect.color = off_colour

	should_show_error_text()

func select_shield(state: bool) -> void:
	audioplayer.stream = blip_sound
	audioplayer.play()

	if _needs_refresh:
		refresh_light_colour()

	if state:
		_current_selections.push_back(PowerState.SHIELD)
		shield_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.SHIELD)
		shield_rect.color = off_colour

	should_show_error_text()

func select_energy(state: bool) -> void:
	audioplayer.stream = blip_sound
	audioplayer.play()

	if _needs_refresh:
		refresh_light_colour()

	if state:
		_current_selections.push_back(PowerState.ENERGY)
		energy_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.ENERGY)
		energy_rect.color = off_colour

	should_show_error_text()

func select_oxygen(state: bool) -> void:
	audioplayer.stream = blip_sound
	audioplayer.play()

	if _needs_refresh:
		refresh_light_colour()

	if state:
		_current_selections.push_back(PowerState.OXYGEN)
		oxygen_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.OXYGEN)
		oxygen_rect.color = off_colour

	should_show_error_text()

func set_light_visibility(array: Array[Light3D], is_on: bool) -> void:
	for l in array:
		l.visible = is_on

func refresh_light_colour() -> void:
	if nav_switch.state == true:
		nav_rect.color = selected_colour
	if oxygen_switch.state == true:
		oxygen_rect.color = selected_colour
	if energy_switch.state == true:
		energy_rect.color = selected_colour
	if shield_switch.state == true:
		shield_rect.color = selected_colour

func update_success_boxes() -> void:
	if not _is_held:
		return

	var index: float = remap(_timer, 0.0, button_hold_timer, 0.0, 6.0)

	for i in success_indicators.size() - 1:
		if float(i + 1) <= index:
			if success_indicators[i].color.a < 1.0:
				audioplayer.stream = blip_sound
				audioplayer.play()
			success_indicators[i].color.a = 1.0
		else:
			success_indicators[i].color.a = 0.0

func reset_success_boxes() -> void:
	audioplayer.stream = success_sound
	audioplayer.play()

	_block_process = true

	for box in success_indicators:
		box.color = on_colour

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

	for box in success_indicators:
		box.color = selected_colour
		box.color.a = 0.0

	_block_process = false


func fail_success_boxes() -> void:
	audioplayer.stream = failure_sound
	audioplayer.play()

	_block_process = true

	for box in success_indicators:
		box.color = off_colour

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

	for box in success_indicators:
		box.color = selected_colour
		box.color.a = 0.0

	_block_process = false


func show_error_text(should_be_shown: bool) -> void:
	if should_be_shown:
		error_text.modulate.a = 1.0
	else:
		error_text.modulate.a = 0.0

func should_show_error_text() -> void:
	if _current_selections.size() > 1:
		show_error_text(true)
	else:
		show_error_text(false)

func set_door_state(door: ShipDoor, state: bool) -> void:
	if door._door_open == not state:
		door._toggle_door()
