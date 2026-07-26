extends AudioStreamPlayer3D

# one in a million chance each frame for the radio to crap out and go demon mode
func _process(delta: float) -> void:
	if randi_range(0, 1000000) == 666:
		pitch_scale = 0.4
		volume_db = -25.0
	
	if randi_range(0, 10000) == 666:
		pitch_scale = 1.0
		volume_db = -30.0
	
	if randi_range(0, 1000000) == 69:
		pitch_scale = 2.0
		volume_db = -30.0
	
	if randi_range(0, 1000000) == 0:
		playing = false
	
	if randi_range(0, 1000000) == 420:
		pitch_scale = 0.8
