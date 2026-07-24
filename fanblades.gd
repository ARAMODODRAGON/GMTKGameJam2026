extends MeshInstance3D

@export var fan_rps: float = 4.0
var oxygen_danger_zone: float = 30

func _process(delta: float) -> void:
	if ShipStats.oxygen_amount > oxygen_danger_zone:
		rotation.z += PI * fan_rps * delta
	else:
		rotation.z += PI * remap(ShipStats.oxygen_amount, 0, oxygen_danger_zone, 0, fan_rps) * delta
