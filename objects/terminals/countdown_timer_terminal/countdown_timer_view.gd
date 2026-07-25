class_name CountdownTimerView
extends Node2D

@export var timer_text: RichTextLabel

func _ready() -> void:
	ShipStats.on_game_timer_amount_changed.connect(update_timer_text)

func update_timer_text(value: float) -> void:
	
	timer_text.text = str(int(value))
