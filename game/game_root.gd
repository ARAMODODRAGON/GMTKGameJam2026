extends Node

## Public Variable

@export var game_length: float = 5.0 * 60.0 ## 5 minutes

@export var win_scene: PackedScene
@export var lose_scene: PackedScene

@export_group("References")
@export var debug_display: RichTextLabel
@export var pause_screen: Control
@export var game_layer: Node

var game_paused: bool = false:
	set(value):
		game_paused = value
		if value:
			pause_screen.visible = true
			game_layer.process_mode = Node.PROCESS_MODE_DISABLED
			ShipStats.pause_timer = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			pause_screen.visible = false
			game_layer.process_mode = Node.PROCESS_MODE_INHERIT
			ShipStats.pause_timer = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Virtual Methods

func _ready() -> void:
	ShipStats.on_lose.connect(_on_game_lose)
	ShipStats.on_win.connect(_on_game_win)
	ShipStats.start_new_game(game_length)

	ShipStats.oxygen_amount = 5.0

func _process(delta: float) -> void:

	if Input.is_action_just_pressed(&"Pause"):
		game_paused = not game_paused


	if not debug_display.visible:
		return

	debug_display.text = ""

	debug_display.text += "time remaining: %.1f\n" % ShipStats.game_timer
	debug_display.text += "oxygen: %.1f\n" % ShipStats.oxygen_amount
	debug_display.text += "alignment: %.1f\n" % ShipStats.alignment_amount
	debug_display.text += "energy: %.1f\n" % ShipStats.energy_amount
	debug_display.text += "shield: %.1f\n" % ShipStats.shield_amount

func _unhandled_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_F7 and keyevent.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		debug_display.visible = !debug_display.visible


## Private Methods

func _on_game_win() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(win_scene)

func _on_game_lose() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(lose_scene)
