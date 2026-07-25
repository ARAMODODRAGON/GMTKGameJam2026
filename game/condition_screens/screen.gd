extends Node

@export var fade_in_rect: ColorRect
@export var focus_item: Control

func _ready() -> void:
	fade_in_rect.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 0.0, 1.0)

	focus_item.grab_focus.call_deferred()


func _on_button_pressed() -> void:
	print("test")
