extends InteractableSwitch

@export var anim: AnimationPlayer


func _ready() -> void:
	state_changed.connect(_state_changed)


func _state_changed(new_value: bool) -> void:
	if new_value:
		anim.play.call_deferred(&"turn_on")
	else:
		anim.play.call_deferred(&"turn_off")
