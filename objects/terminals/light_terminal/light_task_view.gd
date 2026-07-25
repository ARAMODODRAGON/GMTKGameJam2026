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

## Private variables

var _timer: float = 0.0

var _is_held: bool = false

var _needs_refresh: bool = false

var _current_selections: Array[PowerState] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_timer = button_hold_timer
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_held:
		_timer -= delta
		if _timer <= 0:
			_reroute_power()
			_timer = button_hold_timer

func _on_button_held() -> void:
	_is_held = true
	print("Main power held")

func _on_button_released() -> void:
	_is_held = false
	_timer = button_hold_timer
	print("Main power released")

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
			print("Power send to nav")
		PowerState.OXYGEN:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, true)
			set_light_visibility(shield_lights, false)
			set_light_visibility(energy_lights, false)
			oxygen_rect.color = on_colour
			_needs_refresh = true
			print("Power send to oxygen")
		PowerState.ENERGY:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, false)
			set_light_visibility(shield_lights, false)
			set_light_visibility(energy_lights, true)
			energy_rect.color = on_colour
			_needs_refresh = true
			print("Power send to energy")
		PowerState.SHIELD:
			set_light_visibility(nav_lights, false)
			set_light_visibility(oxygen_lights, false)
			set_light_visibility(shield_lights, true)
			set_light_visibility(energy_lights, false)
			shield_rect.color = on_colour
			_needs_refresh = true
			print("Power send to shields")

func select_nav(state: bool) -> void:
	if _needs_refresh:
		refresh_light_colour()
	
	if state:
		_current_selections.push_back(PowerState.NAV)
		nav_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.NAV)
		nav_rect.color = off_colour

func select_shield(state: bool) -> void:
	if _needs_refresh:
		refresh_light_colour()
	
	if state:
		_current_selections.push_back(PowerState.SHIELD)
		shield_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.SHIELD)
		shield_rect.color = off_colour

func select_energy(state: bool) -> void:
	if _needs_refresh:
		refresh_light_colour()
	
	if state:
		_current_selections.push_back(PowerState.ENERGY)
		energy_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.ENERGY)
		energy_rect.color = off_colour

func select_oxygen(state: bool) -> void:
	if _needs_refresh:
		refresh_light_colour()
	
	if state:
		_current_selections.push_back(PowerState.OXYGEN)
		oxygen_rect.color = selected_colour
	else:
		_current_selections.erase(PowerState.OXYGEN)
		oxygen_rect.color = off_colour

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
	