extends Node2D

const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

const DB_VAR = "GAMESTATE_Dialog"

export (NodePath) var switch_path = "" setget _setSwitchPath
export(String) var dialog_src = ""
export(float, 0.0, 5.0) var display_time = 1.0
export(bool) var repeatable = false


var ready = false
var reload_original_source = false
var dialog_node = null
var dialog_playing = false
var dialog_played = false
var dialog_data = null

var dialog_line = 0
var dialog_display_time = 0.0


func _setSwitchPath(np):
	if switch_path != np:
		if ready:
			_disconnectSwitch()
		switch_path = np
		if ready:
			_connectSwitch()

func _connectSwitch():
	var switchNode = get_node_or_null(switch_path)
	if switchNode != null:
		for sig in switchNode.get_signal_list():
			if sig["name"] == SWITCH_ON_SIGNAL:
				switchNode.connect(SWITCH_ON_SIGNAL, self, "_on_switch_on")


func _disconnectSwitch():
	var switchNode = get_node_or_null(switch_path)
	if switchNode != null:
		switchNode.disconnect(SWITCH_ON_SIGNAL, self, "_on_switch_on")

func _loadDialogData(src):
	var file = File.new()
	file.open(src, file.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	if data:
		if not ("lines" in data):
			return null 
	return data

func _configureFromData():
	if "color" in dialog_data:
		dialog_node.get_node("Label").set("custom_colors/font_color", Color(
			dialog_data.color.r,
			dialog_data.color.g,
			dialog_data.color.b,
			1.0	
		))

func _updateDialogPercentage():
	var p = dialog_display_time / display_time
	dialog_node.get_node("Label").percent_visible = p

func _setDialogLine(n):
	if dialog_data.lines.size() > n:
		dialog_node.get_node("Label").text = dialog_data.lines[n]
		dialog_node.get_node("Label").percent_visible = 0.0
		dialog_display_time = 0.0
		return true
	return false

func _ready():
	ready = true
	dialog_node = get_tree().root.get_node("World/UI/Dialog")
	if dialog_src != "":
		dialog_data = _loadDialogData(dialog_src)
		if dialog_data:
			_configureFromData()
			_connectSwitch()
		else:
			print("WARNING: Unable to load or parse dialog data at '", dialog_src, "'.")
	else:
		print("WARNING: No dialog data source set.")

func _input(event):
	if dialog_node.visible:
		if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and not event.is_echo():
			if dialog_display_time < display_time:
				dialog_display_time = display_time
				_updateDialogPercentage()
			else:
				dialog_display_time = 0
				dialog_line = dialog_line + 1
				if not _setDialogLine(dialog_line):
					if "next_src" in dialog_data:
						var ndata = _loadDialogData(dialog_data.next_src)
						if ndata:
							reload_original_source = true
							dialog_data = ndata
							_configureFromData()
							dialog_line = 0
					else:
						if reload_original_source:
							var ndata = _loadDialogData(dialog_src)
							if ndata:
								dialog_data = ndata
								_configureFromData()
							else:
								print("WARNING: Failed to reload original dialog data.")
								repeatable = false # Force non-repeat because something went wrong.
						dialog_playing = false
						dialog_played = true
						dialog_line = 0
						dialog_node.visible = false
						Database.set(DB_VAR, false)


func _process(delta):
	if dialog_node.visible:
		if dialog_display_time < display_time:
			dialog_display_time += delta
			if dialog_display_time > display_time:
				dialog_display_time = display_time
			_updateDialogPercentage()


func _on_switch_on():
	if not dialog_playing:
		if (not dialog_played or repeatable) and dialog_data != null:
			Database.set(DB_VAR, true)
			dialog_node.visible = true
			dialog_node.get_node("Label").text = dialog_data.lines[dialog_line]




