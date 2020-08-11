extends KinematicBody2D


const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

export (NodePath) var switch_path = "" setget _setSwitchPath
export(float) var lift_speed = 50.0
export(float) var lift_acceleration = 0.25
export(float) var fall_speed = 200.0
export(float) var fall_acceleration = 0.75

var ready = false
var motion = Vector2.ZERO

enum State {REST, LOWER, RAISE}
var state = State.REST
var stateSwitched = false

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
	AudioManager.addSFXSample("gate_open", "res://media/audio/sfx/gate_opening.wav", self)
	AudioManager.addSFXSample("gate_close", "res://media/audio/sfx/gate_closing.wav", self)
	_connectSwitch()

func _process(delta):
	if stateSwitched:
		motion = Vector2.ZERO
		stateSwitched = false
	
	if state == State.LOWER:
		motion.y = lerp(motion.y, fall_speed, fall_acceleration * delta)
	elif state == State.RAISE:
		motion.y = lerp(motion.y, -lift_speed, lift_acceleration * delta)
	
	if motion.length() > 0.0:
		var res = move_and_collide(motion)
		if res:
			state = State.REST

func _on_switch_on():
	stateSwitched = true
	state = State.RAISE
	AudioManager.playSFX("gate_open", false, self, 300)

func _on_switch_off():
	stateSwitched = true
	state = State.LOWER
	AudioManager.playSFX("gate_close", false, self, 300)



