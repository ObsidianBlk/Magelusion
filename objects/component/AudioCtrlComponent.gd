extends Node2D

export(NodePath) var audio_player_path

var samples = {}
onready var audioPlayer = get_node(audio_player_path)

func addSample(name: String, path: String):
	if not (name in samples):
		var sample = load(path)
		if not sample:
			print("WARNING: Failed to load sample '", path, "'. Sample not added.")
			return false
		samples[name] = sample
		return true
	return false

func is_playing_sample(name: String):
	if name in samples:
		return audioPlayer.stream == samples[name]
	return false

func is_playing():
	return audioPlayer.playing

func play(name: String):
	if name in samples:
		if audioPlayer.playing:
			audioPlayer.stop()
		audioPlayer.stream = samples[name]
		audioPlayer.play()

func stop():
	audioPlayer.stop()
