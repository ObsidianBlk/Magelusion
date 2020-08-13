extends StaticBody2D


const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

export (NodePath) var switch_path = "" setget _setSwitchPath
export (bool) var out = true setget _setOut

var ready = false
onready var enabled_collision_layer = collision_layer
onready var enabled_collision_mask = collision_mask


func _setOut(o):
	if out != o:
		out = o
		if ready:
			if out:
				$Tween.interpolate_property($Sprite, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$Tween.start()
			else:
				collision_layer = 0
				collision_mask = 0
				$Tween.interpolate_property($Sprite, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$Tween.start()


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
			elif sig["name"] == SWITCH_OFF_SIGNAL:
				switchNode.connect(SWITCH_OFF_SIGNAL, self, "_on_switch_off")

func _disconnectSwitch():
	var switchNode = get_node_or_null(switch_path)
	if switchNode != null:
		switchNode.disconnect(SWITCH_ON_SIGNAL, self, "_on_switch_on")
		switchNode.disconnect(SWITCH_OFF_SIGNAL, self, "_on_switch_off")

func _ready():
	ready = true
	_connectSwitch()
	if not out:
		$Sprite.modulate.a = 0.0
		collision_layer = 0
		collision_mask = 0


func _on_switch_on():
	_setOut(true)

func _on_switch_off():
	_setOut(false)


func _on_tween_all_completed():
	if out:
		print("Modulate Value: ", $Sprite.modulate.a)
		collision_layer = enabled_collision_layer
		collision_mask = enabled_collision_mask
