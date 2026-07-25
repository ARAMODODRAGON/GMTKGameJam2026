extends Node

@export var game_length: float = 5.0 * 60.0 ## 5 minutes

@export_group("References")
@export var debug_display: RichTextLabel


func _ready() -> void:
	ShipStats.start_new_game(game_length)

func _process(delta: float) -> void:
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
