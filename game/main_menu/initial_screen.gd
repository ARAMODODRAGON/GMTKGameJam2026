extends Control

@export var fade_rect: ColorRect

@export var warning_text: RichTextLabel
@export var recommendation_text: RichTextLabel

func _ready() -> void:
	var tween := create_tween()
	warning_text.visible = true
	recommendation_text.visible = false

	tween.tween_property(fade_rect, "color:a", 0.0, 1.0)
	tween.tween_interval(4.0)
	tween.tween_property(fade_rect, "color:a", 1.0, 0.4)
	tween.tween_interval(0.2)

	tween.tween_callback(
		func() -> void:
			warning_text.visible = false
			recommendation_text.visible = true
	)

	tween.tween_property(fade_rect, "color:a", 0.0, 0.4)
	tween.tween_interval(4.0)
	tween.tween_property(fade_rect, "color:a", 1.0, 1.0)

	tween.tween_callback(
		func() -> void:
			get_tree().change_scene_to_file("uid://cto3wh80pmb0w")
	)
