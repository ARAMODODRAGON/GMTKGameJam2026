extends MeshInstance3D


@onready var sound1: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var sound2: AudioStreamPlayer3D = $AudioStreamPlayer3D2

var sound_played: bool = false

func _process(delta: float) -> void:
	if is_equal_approx(ShipStats.game_timer, 0.0) and not sound_played:
		sound1.play() # bang!
		sound2.play() # door sound
		sound_played = true
	if ShipStats.game_timer <= 0:
		position.z += 2.0 * delta
