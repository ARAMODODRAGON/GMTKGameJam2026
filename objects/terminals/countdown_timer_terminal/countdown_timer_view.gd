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
	if ShipStats.game_timer < 1:
		timer_text.text = "Rescue vessel arrived! Head to O2 room airlock immediately."
	else:
		timer_text.text = str(time)
	if _last_count != time:
		_last_count = time
		if ShipStats.game_timer < 1:
			timer_text.text = "Rescue vessel arrived! Head to O2 room airlock immediately."
			audioplayer.stream = load("res://objects/terminals/shared/sounds/escape_now.mp3")
			audioplayer.play()
		else:
			audioplayer.play()
