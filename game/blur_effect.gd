extends ColorRect

@export var blur_noise: Noise
@export var oxygen_blur_start: float = 20.0

@export var normal_reticle: Texture2D
@export var interact_reticle: Texture2D

var _time: float = 0.0
var _amount: float = 0.0


func _ready() -> void:
	EffectsManager._pointer_set_hitting_interactable.connect(_set_hitting_interactable)


func _set_hitting_interactable(state: bool) -> void:
	if state:
		material.set("shader_parameter/pointer_texture", interact_reticle)
	else:
		material.set("shader_parameter/pointer_texture", normal_reticle)

func _process(delta: float) -> void:
	if ShipStats.oxygen_amount < oxygen_blur_start:
		_amount = move_toward(_amount, 1.0 - (ShipStats.oxygen_amount / oxygen_blur_start), delta)
	else:
		_amount = move_toward(_amount, 0.0, delta)

	_time += delta
	#var blur_amount := blur_noise.get_noise_1d(_time)
	#material.set("shader_parameter/blur_amount", remap(blur_amount, -1.0, 1.0, 0.0, 1.0) * _amount)

	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 1.0 - _amount)

func _exit_tree() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 1.0)
