extends Node2D
tool

signal level_exit(next)
signal win_game

export(String) var next_level_src = ""
export(String) var db_key_name = ""
export(bool) var win_game = false
export(Color) var light_color = Color(1.0, 1.0, 1.0, 1.0)
export(Color) var dark_color = Color(0.0, 0.0, 0.0, 1.0)

var bodies = []
var ready = false

func _setLightColor(c):
	c.a = 1.0
	light_color = c
	_updateColors()

func _setDarkColor(c):
	c.a = 1.0
	dark_color = c
	_updateColors()


func _updateColors():
	if ready:
		$DoorLeft.get_material().set_shader_param("COLOR_A_REPLACEMENT", light_color)
		$DoorLeft.get_material().set_shader_param("COLOR_B_REPLACEMENT", dark_color)
		$DoorRight.get_material().set_shader_param("COLOR_A_REPLACEMENT", light_color)
		$DoorRight.get_material().set_shader_param("COLOR_B_REPLACEMENT", dark_color)


func _ready():
	ready = true
	_updateColors()
	

func _addBodyIfNotExist(body):
	if bodies.find(body) < 0:
		bodies.append(body)

func _removeIfExists(body):
	var i = bodies.find(body)
	if i >= 0:
		bodies.remove(i)

func _disconnectAllBodies():
	if bodies.size() > 0:
		for i in range(bodies.size()):
			bodies[i].disconnect("activate", self, "_on_activate")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		_addBodyIfNotExist(body)
		body.connect("activate", self, "_on_activate")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		_removeIfExists(body)
		body.disconnect("activate", self, "_on_activate")


func _on_activate():
	if $DoorLeft.animation == "Closed":
		if db_key_name == "" or Database.get(db_key_name) == true:
			$DoorLeft.play("Opening")
			$DoorRight.play("Opening")
	elif $DoorLeft.animation == "Open":
		if next_level_src != "":
			_disconnectAllBodies()
			if win_game:
				emit_signal("win_game")
			else:
				print("Emitting next level")
				emit_signal("level_exit", next_level_src)


func _on_animation_finished():
	if $DoorLeft.animation == "Opening":
		$DoorLeft.play("Open")
		$DoorRight.play("Open")
	elif $DoorLeft.animation == "Closing":
		$DoorLeft.play("Closed")
		$DoorRight.play("Closed")
