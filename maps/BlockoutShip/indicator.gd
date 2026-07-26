extends MeshInstance3D

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if ShipStats.game_timer <= 0.0:
		visible = true
