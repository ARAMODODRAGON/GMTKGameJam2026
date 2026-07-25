extends ColorRect

@export var blur_noise: Noise
@export var oxygen_blur_start: float = 20.0

var _time: float = 0.0
var _amount: float = 0.0

func _process(delta: float) -> void:
	if ShipStats.oxygen_amount < oxygen_blur_start:
		_amount = move_toward(_amount, 1.0 - (ShipStats.oxygen_amount / oxygen_blur_start), delta)
	else:
		_amount = move_toward(_amount, 0.0, delta)

	_time += delta
	var blur_amount := blur_noise.get_noise_1d(_time)
	material.set("shader_parameter/blur_amount", remap(blur_amount, -1.0, 1.0, 0.0, 1.0) * _amount)
