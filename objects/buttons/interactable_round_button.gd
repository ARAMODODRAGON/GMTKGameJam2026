extends InteractableButton

@export var anim: AnimationPlayer

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


func _released() -> void:
	super()

	_play(&"button_release")
