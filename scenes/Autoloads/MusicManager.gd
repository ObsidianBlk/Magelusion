extends Node

# NOTE: This is not really doing anything special.
# Not enough time in the jam to really "mix" between the two streams

var musicDict = {}
var srcList = []


func _getSourceIndex(src:String):
	if srcList.size() > 0:
		for i in range(srcList.size()):
			if srcList[i].src == src:
				return i
	return -1

func _addSourceIfNotExist(src:String):
	var si = _getSourceIndex(src)
	if si < 0:
		srcList.append({
			"src":src,
			"stream":null
		})
		si = srcList.size() - 1
	return si


func addMusic(name: String, src: String):
	if not (name in musicDict):
		var si = _addSourceIfNotExist(src)
		musicDict[name] = si


func play(name: String):
	if name in musicDict:
		var info = srcList[musicDict[name]]
		if info.stream != null:
			if not info.stream.playing:
				info.stream.play()
		else:
			var stream = load(info.src)
			if stream:
				$Stream1.stream = stream
				$Stream1.play()
				info.stream = $Stream1

func stop():
	$Stream1.stop()



