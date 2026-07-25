extends Node

@export var fade_in_rect: ColorRect
@export var focus_item: Control

@export var debug_display: RichTextLabel

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
	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 0.0, 1.0)

	focus_item.grab_focus.call_deferred()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(&"uid://b305heht0etyb")
