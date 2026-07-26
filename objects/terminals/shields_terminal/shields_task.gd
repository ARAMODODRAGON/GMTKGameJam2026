class_name ShieldsTask
extends Node2D



## Public variables

@export var buttons: Array[InteractableButton] = [] # the three buttons for filling the batteries

@export var lockout_switch: InteractableSwitch # the lockout switch to edit shield batteries and then confirm changes

@export var sfx_player: AudioStreamPlayer3D # speaker for the terminal to bleep and bloop

@export var stat_success_amount: float = 0.0
@export var stat_failure_amount: float = 0.0

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var shield_battery_drain_rate: float = 0.0

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var shield_battery_refill_rate: float = 0.0

@export_custom(PROPERTY_HINT_NONE, "suffix:/s")
var stat_usage_rate: float = 1.0

## Private variables

var _shield_battery_fill_amounts: Array[float] = [50.0, 50.0, 50.0]
var _shield_battery_filling: int = -1

@export var _shield_batteries: Array[Sprite2D] = [] # specifically the fill sprite, just move it up and down. the rest is basically decorative

@export var _shield_faces: Array[AnimatedSprite2D] = [] # the little faces that indicate fillingness

@export var _padlock_icon: AnimatedSprite2D # lockout icon

@export var _locked_banner: Sprite2D # lockout banner



var _task_locked: bool = true


var _sfx_played: bool = false

var _successes: int = 0

var _timer: float

## Signals
signal on_shields_terminal_success()
signal on_shields_terminal_completion()
signal on_shields_terminal_failure()

## Private functions
func _ready() -> void:

	if (not buttons[0]) or (not buttons[1]) or (not buttons[2]):
		print("a button was found to be null")
		return

	if (not _shield_batteries[0]) or (not _shield_batteries[1]) or (not _shield_batteries[2]):
		print("a shield battery was found to be null")
		return

	if (not _shield_faces[0]) or (not _shield_faces[1]) or (not _shield_faces[2]):
		print("a shield face was found to be null")
		return

	for i in 3:
		buttons[i].pressed.connect(_start_fill.bind(i))
		buttons[i].released.connect(_end_fill.bind(i))


	lockout_switch.state_changed.connect(_lockout_state_change)


func _process(delta: float) -> void:
	# if _timer > 0:
	# 	_timer -= delta
	# 	if _timer <= 0:
	# 		_can_move = true


	ShipStats.shield_amount -= stat_usage_rate * delta * ShipStats.difficulty_multiplier # drain the overall shield stat at a constant rate

	# update the battery charge fill amounts (approx 7/10 is the green line)
	for i in 3:
		# default to sad face if out of correct range
		if _shield_battery_fill_amounts[i] < 60.0 or _shield_battery_fill_amounts[i] > 90.0 :
			_shield_faces[i].frame = 0 # sad face

		# drain or fill the battery
		if _shield_battery_filling == i:
			_shield_battery_fill_amounts[i] += shield_battery_refill_rate * delta
			_shield_faces[i].frame = 1 # meh face override if currently filling this battery
		else:
			if _task_locked:
				# stay put while locked
				pass
			else:
				# drain at a constant rate while unlocked
				_shield_battery_fill_amounts[i] -= (shield_battery_drain_rate * delta)

		# finally, happyface if it's correct
		if _shield_battery_fill_amounts[i] > 60.0 and _shield_battery_fill_amounts[i] < 90.0:
			_shield_faces[i].frame = 2 # happy face if in the good zone

		# clamp it.
		if _shield_battery_fill_amounts[i] > 100.0:
			_shield_battery_fill_amounts[i] = 100.0
		elif _shield_battery_fill_amounts[i] < 0.0:
			_shield_battery_fill_amounts[i] = 0.0

		_shield_batteries[i].position.y = remap(_shield_battery_fill_amounts[i], 0, 100, 49.5, 4.5) # set the height of the fill indicator

		# print("battery " + str(i) + " is fill level " + str(_shield_battery_fill_amounts[i]))




func _start_fill(index: int) -> void:
	# no filling for you if it's locked.
	if _task_locked:
		sfx_player.stream = load("res://objects/terminals/shared/sounds/small_bad.mp3") # bad noise (it's locked)
		sfx_player.play()
	else:
		_shield_battery_filling = index

		# start playing the clicking while filling
		sfx_player.stream = load("res://objects/terminals/shared/sounds/hold_clicking.mp3")
		sfx_player.play()

func _end_fill(index: int) -> void:
	_shield_battery_filling = -1

	if _shield_battery_fill_amounts[index] > 60.0 and _shield_battery_fill_amounts[index] < 90.0:
		on_shields_terminal_success.emit() # released the button with the battery in the right fill zone

		sfx_player.stream = load("res://objects/terminals/shared/sounds/small_good.mp3") # good noise
		sfx_player.play()


	sfx_player.stop()


func _lockout_state_change(_whatever: bool) -> void:
	if lockout_switch.state == true:
		_unlock_task()
	else:
		_lock_task()

# unlock the task to be edited
func _unlock_task() -> void:
	_padlock_icon.frame = 1 # unlocked fram
	_task_locked = false

	sfx_player.stream = load("res://objects/terminals/shared/sounds/impact_small.mp3")
	sfx_player.play()

	# rescramble the battery fill amounts
	_shield_battery_fill_amounts[0] = (randf_range(0, 100))
	_shield_battery_fill_amounts[1] = (randf_range(0, 100))
	_shield_battery_fill_amounts[2] = (randf_range(0, 100))

	_locked_banner.hide()

# lock in your changes
func _lock_task() -> void:
	_task_locked = true
	_locked_banner.show()

	_padlock_icon.frame = 0 # locked frame
	# i know this sucks (whatever i do not care)
	if (_shield_battery_fill_amounts[0] > 60.0 and _shield_battery_fill_amounts[0] < 90.0) and (_shield_battery_fill_amounts[1] > 60.0 and _shield_battery_fill_amounts[1] < 90.0) and (_shield_battery_fill_amounts[2] > 60.0 and _shield_battery_fill_amounts[2] < 90.0):
		#all shields are in correct charge range. completed the task
		on_shields_terminal_completion.emit()
		sfx_player.stream = load("res://objects/terminals/shared/sounds/impact_small_good.mp3")
		sfx_player.play()

		ShipStats.shield_amount += stat_success_amount




	else:
		# something's wrong bub. failed the task.
		on_shields_terminal_failure.emit()
		sfx_player.stream = load("res://objects/terminals/shared/sounds/impact_small_bad.mp3")
		sfx_player.play()

		ShipStats.shield_amount -= stat_failure_amount
