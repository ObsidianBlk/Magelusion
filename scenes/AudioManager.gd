extends Node

const SFX_PREFIX = "__SFX__"
const MUSIC_PREFIX = "__MUSIC__"

var musicDict = {}
var sfxDict = {}
var streamsDict = {}


func _GetOldestSFXPlayer():
	var last_child = null
	
	for child in $SFX.get_children():
		if last_child == null:
			last_child = child
		elif child.get_playback_position() > last_child.get_playback_position():
			last_child = child
	return last_child

func _GetSFXPlayFromSample(sample):
	for child in $SFX.get_children():
		if child.stream == sample:
			return child
	return null

func _GetSample(path):
	if path in streamsDict:
		return streamsDict[path].sample
	return null

func _GetRefIndex(path, ref):
	if path in streamsDict:
		for i in range(streamsDict[path].refs.size()):
			if streamsDict[path].refs[i] == ref:
				return i
	return -1

func _AddSample(type, dict, name, path, ref):
	if name in dict:
		if dict[name] != path:
			print ("WARNING: ", type, " '", name, "' already used by another ", type, " sample! Ignoring!")
		else:
			if _GetRefIndex(path, ref) < 0:
				streamsDict[path].refs.append(ref)
	else:
		var stream = load(path)
		if stream:
			streamsDict[path] = {
				"sample": stream,
				"refs": []
			}
			streamsDict[path].refs.append(ref)
			dict[name] = path
		else:
			print("WARNING: Failed to load ", type, " stream '", path, "'. Ignoring!")

func _RemoveSample(path, ref):
	# Removes the reference object from the streamsDict if both exist. If all references are removed
	# function will return true, otherwise false
	var rindex = _GetRefIndex(path, ref)
	if rindex >= 0:
		streamsDict[path].refs.remove(rindex)
		if streamsDict[path].ref.size() <= 0:
			streamsDict.erase(path)
			return true
	return false

func addSFXSample(name : String, path : String, ref : Node):
	_AddSample("SFX", sfxDict, name, path, ref)

func removeSFXSample(name : String, ref : Node):
	if name in sfxDict:
		if _RemoveSample(sfxDict[name], ref):
			sfxDict.erase(name)

func addMusicSample(name : String, path : String, ref : Node):
	_AddSample("Music", musicDict, name, path, ref)

func removeMusicSample(name : String, ref : Node):
	if name in musicDict:
		if _RemoveSample(musicDict[name], ref):
			musicDict.erase(name)


func playMusic(name : String):
	if name in musicDict:
		var sample = _GetSample(musicDict[name])
		if sample != null:
			if $Music/Stream1.stream != sample:
				$Music/Stream1.stop()
				$Music/Stream1.stream = sample
				$Music/Stream1.play()
			return true # regardless, the sample was found and is playing!
	print("WARNING: Cannot play music '", name, "'. Not found in sample library.")
	return false


func playSFX(name : String, loop : bool = false, target : Node2D = null, distance : float = 2000):
	if name in sfxDict:
		var sample = _GetSample(sfxDict[name])
		if sample != null:
			var player = _GetOldestSFXPlayer()
			if player != null:
				if "loop_mode" in sample:
					print(sample.loop_mode)
					if loop:
						sample.loop_mode = AudioStreamSample.LOOP_FORWARD
						sample.loop_begin = 0
						sample.loop_end = sample.get_length() * sample.mix_rate
					else:
						sample.loop_mode = AudioStreamSample.LOOP_DISABLED
				else:
					sample.set_loop(loop)
				player.stop()
				player.stream = sample
				#player.stream.set_loop(loop)
				if target != null:
					player.global_position = target.global_position
					player.max_distance = distance
				player.play()
			return true
	print("WARNING: Cannot play SFX '", name, "'. Not found in sample library.")
	return false

func stopSFX(name : String):
	if name in sfxDict:
		var sample = _GetSample(sfxDict[name])
		if sample != null:
			var player = _GetSFXPlayFromSample(sample)
			if player != null:
				player.stop()





