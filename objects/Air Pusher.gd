extends Node2D
tool

const SWITCH_ON_SIGNAL = "switchOn"
const SWITCH_OFF_SIGNAL = "switchOff"

export (NodePath) var switch_path = "" setget _setSwitchPath
export (bool) var enabled = true setget _setEnabled
export (float, 1.0, 100.0) var width = 4 setget _setWidth
export (float, 1.0, 100.0) var height = 4 setget _setHeight
export (float) var force = 98 setget _setForce
export (float, 0.0, 360.0) var angle = 0.0 setget _setAngle
export (float) var falloff_distance = 0.0 setget _setFalloff


var ready = false
var player = null

onready var collision_masks = $Area2D.collision_mask
onready var collision_layer = $Area2D.collision_layer

func _setForce(f):
	force = f
	_updateInnerNodes()

func _setAngle(a):
	angle = a
	_updateInnerNodes()

func _setFalloff(fo):
	print("Initial FO: ", fo)
	falloff_distance = fo
	if fo > height:
		falloff_distance = height - 0.01
	elif fo < 0.0:
		falloff_distance = 0.0
	print("Result FO: ", falloff_distance)

func _setEnabled(e):
	enabled = e
	_updateInnerNodes()

func _setWidth(w):
	width = w
	_updateInnerNodes()

func _setHeight(h):
	height = h
	_updateInnerNodes()

func _setSwitchPath(np):
	if switch_path != np:
		if ready:
			_disconnectSwitch()
		switch_path = np
		if ready:
			_connectSwitch()

func _updateInnerNodes():
	if ready:
		if enabled:
			$Area2D.collision_layer = collision_layer
			$Area2D.collision_mask = collision_masks
			#$Area2D.set_collision_layer_bit(0, true)
			#$Area2D.set_collision_mask_bit(0, true)
			$Particles2D.emitting = true
			
			$Area2D/CollisionShape2D.shape.extents = Vector2(width * 0.5, height * 0.5)
			$Particles2D.process_material.emission_box_extents = Vector3(width * 0.5, 1.0, 1.0)
			
			$Area2D.position = Vector2(width * 0.5, -height * 0.5)
			$Particles2D.position = Vector2(width * 0.5, 0.0)
			
			var gv = Vector2(0.0, 1.0).rotated(deg2rad(angle))
			$Area2D.gravity = force
			$Area2D.gravity_vec = gv
		else:
			$Area2D.collision_layer = 0
			$Area2D.collision_mask = 0
			#$Area2D.set_collision_layer_bit(0, false)
			#$Area2D.set_collision_mask_bit(0, false)
			$Particles2D.emitting = false
			player = null

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

# Called when the node enters the scene tree for the first time.
func _ready():
	ready = true
	_updateInnerNodes()
	_connectSwitch()


func _process(delta):
	if player != null:
		var pv = $Area2D.gravity_vec * $Area2D.gravity
		var dist = global_position.distance_to(player.global_position)
		var strength = 1.0
		if falloff_distance > 0.0:
			if dist > falloff_distance:
				strength = 1.0 - ((dist - falloff_distance) / (height - falloff_distance))
			else:
				strength = falloff_distance / dist
		else:
			strength = height / dist
		player.push(pv * strength * delta)


func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("push"):
		player = body


func _on_body_exited(body):
	if body == player:
		player = null

func _on_switch_on():
	_setEnabled(true)

func _on_switch_off():
	_setEnabled(false)


