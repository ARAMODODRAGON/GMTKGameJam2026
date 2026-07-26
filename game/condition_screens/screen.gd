extends Node

@export var fade_in_rect: ColorRect
@export var focus_item: Control
@export var death_description: RichTextLabel
@export var audioplayer: AudioStreamPlayer

@export var debug_display: RichTextLabel

var _exiting: bool = false

func _process(delta: float) -> void:
	if not debug_display.visible:
		return

	debug_display.text = ""

	debug_display.text += "time remaining: %.1f\n" % ShipStats.game_timer
	debug_display.text += "oxygen: %.1f\n" % ShipStats.oxygen_amount
	debug_display.text += "alignment: %.1f\n" % ShipStats.alignment_amount
	debug_display.text += "energy: %.1f\n" % ShipStats.energy_amount
	debug_display.text += "shield: %.1f\n" % ShipStats.shield_amount

func _ready() -> void:
	fade_in_rect.color.a = 1.0
	audioplayer.volume_linear = 0.0
	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 0.0, 1.0)
	tween.parallel().tween_property(audioplayer, "volume_linear", 1.0, 3.0)

	focus_item.grab_focus.call_deferred()

	if death_description:
		_updated_death_description()


func _unhandled_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent and keyevent.keycode == KEY_F7 and keyevent.pressed:
		debug_display.visible = not debug_display.visible


func _on_try_again_button_pressed() -> void:
	if _exiting:
		return
	_exiting = true

	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 1.0, 3.0)
	tween.parallel().tween_property(audioplayer, "volume_linear", 0.0, 3.0)

	await tween.finished

	get_tree().change_scene_to_file(&"uid://b305heht0etyb")

func _updated_death_description() -> void:
	if is_equal_approx(ShipStats.shield_amount, 0.0):
		death_description.text = "The ship was hit by an asteroid"

	elif is_equal_approx(ShipStats.oxygen_amount, 0.0):
		death_description.text = "Died of hypoxia"

	elif is_equal_approx(ShipStats.energy_amount, 0.0):
		death_description.text = "You were plunged into darkness"

	elif is_equal_approx(ShipStats.alignment_amount, 0.0):
		death_description.text = "The ship had a fatal collision"


func _on_main_menu_button_pressed() -> void:
	if _exiting:
		return
	_exiting = true

	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 1.0, 3.0)
	tween.parallel().tween_property(audioplayer, "volume_linear", 0.0, 3.0)

	await tween.finished

	get_tree().change_scene_to_file(&"uid://cto3wh80pmb0w")
