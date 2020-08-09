extends Node2D
tool

export (bool) var enabled = true setget _setEnabled
export (float) var force = 98 setget _setForce
export (float, 0.0, 360.0) var angle = 0.0 setget _setAngle
export (float) var falloff_distance = 0.0 setget _setFalloff
export (float, 1.0, 100.0) var width = 4 setget _setWidth
export (float, 1.0, 100.0) var height = 4 setget _setHeight


var ready = false
var player = null

func _setForce(f):
	force = f
	_updateInnerNodes()

func _setAngle(a):
	angle = a
	_updateInnerNodes()

func _setFalloff(fo):
	falloff_distance = fo
	if fo > height:
		falloff_distance = height
	elif fo < 0.0:
		falloff_distance = 0.0

func _setEnabled(e):
	enabled = e
	_updateInnerNodes()

func _setWidth(w):
	width = w
	_updateInnerNodes()

func _setHeight(h):
	height = h
	_updateInnerNodes()

func _updateInnerNodes():
	if ready:
		if enabled:
			$Area2D.set_collision_layer_bit(0, true)
			$Particles2D.emitting = true
			
			$Area2D/CollisionShape2D.shape.extents = Vector2(width * 0.5, height * 0.5)
			$Particles2D.process_material.emission_box_extents = Vector3(width * 0.5, 1.0, 1.0)
			
			$Area2D.position = Vector2(width * 0.5, -height * 0.5)
			$Particles2D.position = Vector2(width * 0.5, 0.0)
			
			var gv = Vector2(0.0, 1.0).rotated(deg2rad(angle))
			$Area2D.gravity = force
			$Area2D.gravity_vec = gv
		else:
			$Area2D.set_collision_layer_bit(0, false)
			$Particles2D.emitting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ready = true
	_updateInnerNodes()


func _process(delta):
	if player != null:
		var pv = $Area2D.gravity_vec * $Area2D.gravity
		if falloff_distance > 0.0:
			var dist = global_position.distance_to(player.global_position)
			if dist > falloff_distance:
				var falloff = 1.0 - ((dist - falloff_distance) / (height - falloff_distance))
				pv *= falloff
		player.push(pv * delta)


func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("push"):
		player = body


func _on_body_exited(body):
	if body == player:
		player = null
