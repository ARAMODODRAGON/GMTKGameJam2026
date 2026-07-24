extends AudioStreamPlayer3D


func _process(delta: float) -> void:
	if ShipStats.oxygen_amount > 30:
		volume_db = -20
		pitch_scale = 1
	elif ShipStats.oxygen_amount > 0:
		volume_db = remap(ShipStats.oxygen_amount, 0, 30, -30.0, -20.0)
		pitch_scale = remap(ShipStats.oxygen_amount, 0, 30, 0.5, 1.0)
		stream_paused = false
	else:
		stream_paused = true
