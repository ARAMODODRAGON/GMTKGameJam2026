extends InteractableButton

@export var anim: AnimationPlayer
@export var sound_press: AudioStreamPlayer3D
@export var sound_release: AudioStreamPlayer3D

func _play(anim_name: StringName) -> void:
	anim.play(anim_name)
	# if anim.is_playing():
	# 	anim.queue(anim_name)
	# 	print("queued ", anim_name)
	# else:
	# 	anim.play(anim_name)
	# 	print("played ", anim_name)

func _pressed() -> void:
	super()

	_play(&"button_push_down")
	sound_press.play()


func _released() -> void:
	super()

	_play(&"button_release")
	sound_release.play()
