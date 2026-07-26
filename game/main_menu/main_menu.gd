extends Control

@export var game_scene: String

@export var button: Button
@export var fade_in_rect: ColorRect
@export var audioplayer: AudioStreamPlayer
@export var focus_item: Control


var _exiting: bool = false

func _ready() -> void:
	fade_in_rect.color.a = 1.0
	audioplayer.volume_linear = 0.0
	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 0.0, 1.0)
	tween.parallel().tween_property(audioplayer, "volume_linear", 1.0, 3.0)

	focus_item.grab_focus.call_deferred()

func _on_button_pressed() -> void:
	if _exiting:
		return
	_exiting = true

	var tween := create_tween()
	tween.tween_property(fade_in_rect, "color:a", 1.0, 3.0)
	tween.parallel().tween_property(audioplayer, "volume_linear", 0.0, 3.0)

	await tween.finished

	get_tree().change_scene_to_file(game_scene)
