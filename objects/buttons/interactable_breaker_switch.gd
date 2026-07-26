extends InteractableSwitch

@export var anim: AnimationPlayer
@export var audioplayer: AudioStreamPlayer3D


func _ready() -> void:
	state_changed.connect(_state_changed)
	#print("connected")

	if state:
		anim.play(&"turn_on")
	else:
		anim.play(&"turn_off")

	anim.advance(1000.0)


func _state_changed(new_value: bool) -> void:
	audioplayer.play()
	#print("test")
	if new_value:
		anim.play.call_deferred(&"turn_on")
	else:
		anim.play.call_deferred(&"turn_off")
