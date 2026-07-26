class_name CountdownTimerView
extends Node2D

@export var timer_text: RichTextLabel
@export var audioplayer: AudioStreamPlayer3D

var _last_count: int = 0

func _ready() -> void:
	ShipStats.on_game_timer_amount_changed.connect(update_timer_text)
	_last_count = int(ShipStats.game_timer)

func update_timer_text(value: float) -> void:
	var time := int(value)
	timer_text.text = str(time)
	if _last_count != time:
		_last_count = time
		audioplayer.play()
