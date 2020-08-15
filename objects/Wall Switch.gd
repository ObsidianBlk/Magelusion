extends Area2D
tool


export(bool) var on = false
export(float) var off_timer = 0.0
export(Color) var color_a = Color(1.0, 1.0, 1.0, 1.0) setget _setColorA
export(Color) var color_b = Color(0.0, 0.0, 0.0, 1.0) setget _setColorB

signal switchOn
signal switchOff

var ready = false
var cur_off_timer = 0.0

func _setColorA(c):
	c.a = 1.0
	color_a = c
	_updateColors()

func _setColorB(c):
	c.a = 1.0
	color_b = c
	_updateColors()

func _updateColors():
	if ready:
		$AnimatedSprite.get_material().set_shader_param("COLOR_A_REPLACEMENT", color_a)
		$AnimatedSprite.get_material().set_shader_param("COLOR_B_REPLACEMENT", color_b)

func _ready():
	ready = true
	_updateColors()
	if on:
		$AnimatedSprite.animation = "On"
		cur_off_timer = off_timer
	else:
		$AnimatedSprite.animation = "Off"

func _process(delta):
	if cur_off_timer > 0.0:
		cur_off_timer -= delta
		if cur_off_timer <= 0.0:
			$AnimatedSprite.play("SwitchOff")
			_playAudio()


func _playAudio():
	$AudioStream.play()


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.connect("activate", self, "_on_activate")


func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.disconnect("activate", self, "_on_activate")

func _on_activate():
	if $AnimatedSprite.animation == "On":
		$AnimatedSprite.play("SwitchOff")
		_playAudio()
	elif $AnimatedSprite.animation == "Off":
		$AnimatedSprite.play("SwitchOn")
		_playAudio()


func _on_animation_finished():
	if $AnimatedSprite.animation == "SwitchOn":
		$AnimatedSprite.play("On")
		emit_signal("switchOn")
		cur_off_timer = off_timer
	elif $AnimatedSprite.animation == "SwitchOff":
		$AnimatedSprite.play("Off")
		emit_signal("switchOff")
