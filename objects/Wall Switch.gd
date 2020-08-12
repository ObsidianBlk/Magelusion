extends Area2D
tool


export(bool) var on = false
export(float) var off_timer = 0.0

signal switchOn
signal switchOff

var cur_off_timer = 0.0

func _ready():
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
