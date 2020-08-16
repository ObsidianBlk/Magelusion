extends StaticBody2D

export(Array, String) var trigger_groups
export(Array, int) var trigger_count
export(bool) var single_trigger = false
export(bool) var locked = false
export(bool) var invert = false

signal switchOn
signal switchOff

enum STATE{UP, DOWN}

var bodies = {}
var no_trigger = false


func _addBody(group : String, body : Node2D):
	if not (group in bodies):
		bodies[group] = []
	bodies[group].append(body)
	return bodies[group].size()

func _removeBody(group : String, body : Node2D):
	if group in bodies:
		for i in range(bodies[group].size()):
			if bodies[group][i] == body:
				bodies[group].remove(i)
				return true
	return false

func _bodiesInGroup(group : String):
	if group in bodies:
		return bodies[group].size()
	return 0

func _isTriggered():
	if trigger_groups.size() > 0:
		for i in range(trigger_groups.size()):
			var tcount = _getTriggerCountForGroup(trigger_groups[i])
			var bcount = _bodiesInGroup(trigger_groups[i])
			if tcount > 0 and _bodiesInGroup(trigger_groups[i]) >= tcount:
				return true
	return false

func _getTriggerGroupIndex(group : String):
	if trigger_groups.size() > 0 and group != "":
		for i in range(trigger_groups.size()):
			if trigger_groups[i] == group:
				return i
	return -1

func _getTriggerCountForGroup(group : String):
	var gi = _getTriggerGroupIndex(group)
	if gi >= 0:
		if trigger_count.size() > gi:
			return trigger_count[gi]
	return 0

func _getTriggerGroup(obj : Node2D):
	if trigger_groups.size() > 0:
		for trigger_group in trigger_groups:
			if obj.is_in_group(trigger_group):
				return trigger_group
	return ""


func _setState(state):
	match state:
		STATE.UP:
			$AnimatedSprite.animation = "Up"
		STATE.DOWN:
			$AnimatedSprite.animation = "Down"

func _on_body_entered(body):
	if no_trigger:
		return

	var group = _getTriggerGroup(body)
	if group != "":
		var tcount = _getTriggerCountForGroup(group)
		if tcount > 0:
			_addBody(group, body)
			if _isTriggered() and $AnimatedSprite.animation != "Down":
				_setState(STATE.DOWN)
				$AudioStream.play()
				if invert:
					emit_signal("switchOff")
				else:
					emit_signal("switchOn")
				if single_trigger:
					no_trigger = true



func _on_body_exited(body):
	var group = _getTriggerGroup(body)
	if group != "":
		if _removeBody(group, body):
			if not _isTriggered() and $AnimatedSprite.animation != "Up":
				_setState(STATE.UP)
				if not (single_trigger and locked):
					$AudioStream.play()
					if invert:
						emit_signal("switchOn")
					else:
						emit_signal("switchOff")

