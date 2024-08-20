extends Node

var volume_tween
var pitch_tween



func _on_game_shrink_sound_start() -> void:
	$".".pitch_scale = 0.25
	
	# fade the volume in
	if volume_tween:
		volume_tween.kill()
	volume_tween = create_tween()
	volume_tween.tween_property($".", "volume_db", 10, 0.1)

	# fade the pitch up
	if pitch_tween:
		pitch_tween.kill()
	pitch_tween = create_tween()
	pitch_tween.tween_property($".", "pitch_scale", 1, 0.5)


func _on_game_shrink_sound_stop() -> void:
	# fade the volume out
	if volume_tween:
		volume_tween.kill()  # stops tween if currenly running
	volume_tween = create_tween()  # create tween and assing to variable
	volume_tween.tween_property($".", "volume_db", -80, 2)  # ASP, Property, dBValue, time (seconds)

	# fade the pitch down
	if pitch_tween:
		pitch_tween.kill()
	pitch_tween = create_tween()
	pitch_tween.tween_property($".", "pitch_scale", 0.25, 1)
