extends Node2D

const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

const DB_VAR = "GAMESTATE_Dialog"

export (NodePath) var switch_path = "" setget _setSwitchPath
export(String) var dialog_src = ""
export(float) var auto_start_time = 0.0
export(float, 0.0, 5.0) var display_time = 1.0
export(bool) var repeatable = false


var ready = false
var handle_autostart = true
var reload_original_source = false
var dialog_node = null
var dialog_playing = false
var dialog_played = false
var dialog_data = null

var accept_input = true
var input_accept_delay_time = 0.25
var input_accept_delay = 0.0

var attempt_cancel = false
var dialog_cancel_time = 0.5
var dialog_cancel_delay = 0.0

var dialog_line = 0
var dialog_display_time = 0.0

signal switchOn
signal switchOff

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

func _setDialogLine(n, triggers_only = false):
	if dialog_data.lines.size() > n:
		var type = typeof(dialog_data.lines[n])
		var line = ""
		if type == TYPE_DICTIONARY:
			if not ("text" in dialog_data.lines[n]):
				return false
			line = dialog_data.lines[n].text
			if "switch" in dialog_data.lines[n]:
				if dialog_data.lines[n].switch == true:
					emit_signal("switchOn")
				elif dialog_data.lines[n].switch == false:
					emit_signal("switchOff")
		elif type == TYPE_STRING:
			line = dialog_data.lines[n]
		else:
			return false

		if not triggers_only:
			dialog_node.get_node("Label").text = line
			dialog_node.get_node("Label").percent_visible = 0.0
			dialog_display_time = 0.0
		return true
	return false


func _skipDialog():
	# Run through every line, just to make sure we trigger everything
	# because otherwise we might trap the player!
	dialog_line += 1
	while _setDialogLine(dialog_line) == true:
		dialog_line += 1

func _dialogEnd():
	dialog_playing = false
	dialog_played = true
	dialog_line = 0
	dialog_node.visible = false
	Database.set(DB_VAR, false)


func _ready():
	ready = true
	if switch_path != "":
		handle_autostart = false
	dialog_node = get_tree().root.get_node("World/UI/Dialog")
	if dialog_src != "":
		dialog_data = _loadDialogData(dialog_src)
		if dialog_data:
			_connectSwitch()
		else:
			print("WARNING: Unable to load or parse dialog data at '", dialog_src, "'.")
	else:
		print("WARNING: No dialog data source set.")

func _input(event):
	if dialog_playing and dialog_node.visible:
		if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and not event.is_echo():
			if event.is_action_pressed("p1_cast"):
				if attempt_cancel:
					_skipDialog()
					_dialogEnd()
				else:
					attempt_cancel = true
			
			if not accept_input:
				return
			input_accept_delay = input_accept_delay_time
			accept_input = false

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
						_dialogEnd()


func _process(delta):
	if handle_autostart and auto_start_time > 0:
		auto_start_time -= delta
		if auto_start_time <= 0.0:
			_on_switch_on()

	if dialog_playing and dialog_node.visible:
		if attempt_cancel:
			dialog_cancel_delay += delta
			if dialog_cancel_delay >= dialog_cancel_time:
				dialog_cancel_delay = 0.0
				attempt_cancel = false
		
		if input_accept_delay > 0.0:
			input_accept_delay -= delta
			if input_accept_delay <= 0.0:
				accept_input = true

		if dialog_display_time < display_time:
			dialog_display_time += delta
			if dialog_display_time > display_time:
				dialog_display_time = display_time
			_updateDialogPercentage()


func _on_switch_on():
	if not dialog_playing:
		if not handle_autostart:
			# This should allow for a pause before dialog starts but after a trigger
			# sends the 'switchOn' event!
			handle_autostart = true
		elif (not dialog_played or repeatable) and dialog_data != null:
			if DB_VAR != "":
				Database.set(DB_VAR, true)
			dialog_playing = true
			_configureFromData()
			dialog_node.visible = true
			dialog_node.get_node("Label").text = dialog_data.lines[dialog_line]




