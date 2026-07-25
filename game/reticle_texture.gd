extends TextureRect

@export var normal_reticle: Texture2D
@export var interact_reticle: Texture2D


func _ready() -> void:
	EffectsManager._pointer_set_hitting_interactable.connect(_set_hitting_interactable)


func _set_hitting_interactable(state: bool) -> void:
	if state:
		texture = interact_reticle
	else:
		texture = normal_reticle
