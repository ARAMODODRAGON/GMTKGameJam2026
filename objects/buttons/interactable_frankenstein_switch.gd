extends InteractableButton

@export var anim: AnimationPlayer
@export var sound_down: AudioStreamPlayer3D
@export var sound_up_fast: AudioStreamPlayer3D


func _ready() -> void:
	anim.play(&"switch_up_fast")


func _pressed() -> void:
	super()

	anim.speed_scale = 1.0
	anim.play(&"switch_down")
	sound_down.play()


func _released() -> void:
	super()
	sound_down.stop()
	sound_up_fast.play()

	if anim.current_animation_position < 1.9:
		anim.speed_scale = -2.0
	else:
		anim.play(&"switch_up_fast")
