extends Node2D
tool


const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

export (NodePath) var switch_path = "" setget _setSwitchPath
export (bool) var ignore_particles = false
export(float, 0.1, 10.0, 0.01) var base_energy = 1.0
export(float, 0.1, 10.0, 0.01) var base_scale = 1.0
export(bool) var lit = true setget _setLit

var time = 0
var ready = false

signal fireLit(obj)
signal fireUnlit(obj)


func is_lit():
	return $fire.visible

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


func _setLit(l, emit = true):
	lit = l
	if ready:
		$fire.visible = lit
		$Light2D.visible = lit
		if emit:
			if lit:
				emit_signal("fireLit", self)
			else:
				emit_signal("fireUnlit", self)

func _ready():
	ready = true
	if switch_path != "":
		_connectSwitch()
	_setLit(lit, false)

func _process(delta):
	time += delta * 75
	var n = ($fire.get_material().get_shader_param("noise") as NoiseTexture)
	var offset = n.noise.get_noise_1d(time)
	$Light2D.scale = Vector2(base_scale + offset/3, base_scale + offset/3)
	$Light2D.energy = base_energy + offset/3


func _on_body_entered(body):
	if not ignore_particles:
		if body.is_in_group("Fire") and not lit:
			_setLit(true)
		elif body.is_in_group("Water") and lit:
			_setLit(false)

func _on_switch_on():
	_setLit(true)

func _on_switch_off():
	_setLit(false)
